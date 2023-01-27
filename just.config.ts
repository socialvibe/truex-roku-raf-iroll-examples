import { copyTask } from 'just-scripts';
import { hideBin } from 'yargs/helpers';
import { task, logger, series } from 'just-task';
import { isEmpty } from 'lodash';
import { resolve } from 'path';
import { stripIndent } from 'common-tags';
import { TaskCallback, TaskFunction } from 'undertaker';
import { publish, zipPackage } from 'roku-deploy';
import { XMLParser } from 'fast-xml-parser';
import { URLSearchParams, URL } from 'url';
import { randomUUID } from 'crypto';

import fs from 'fs/promises';
import yargs from 'yargs';
import fetch from 'node-fetch';

const defaultTADuration = 20;
const defaultPreviewType = 'raf-ssai-sponsored-ad-break';
const defaultTrueXAdTag = 'https://qa-get.truex.com/50f0b0944f3a826e6d73c8895cb868fb2af0171c/vast/connected_device/inline?network_user_id=truex_engagement_test_user_001';

const version = process.env.npm_package_version as string;
const options = yargs(hideBin(process.argv))
  .option('device-ip', { type: 'string' })
  .option('device-pass', { type: 'string' })
  .option('device-signing-key', { type: 'string' })
  .option('preview-uri', { type: 'string' })
  .option('truex-ad-tag', { type: 'string', default: defaultTrueXAdTag })
  .option('use-test-params', { type: 'boolean', default: true })
  .help('info')
  .parseSync()
;

type Options = typeof options;

task('package-and-run', async (done: TaskCallback): Promise<void> => {
  const device = await resolveDeviceConfig(options);
  const previewCfg = await resolvePreviewConfig(options);

  console.dir(previewCfg);

  series(
    createAppSideloadPackage(options, version, previewCfg),
    uploadAndRunAppSideloadPackage(options, device),
  )(done);
});

task('package', async (done: TaskCallback): Promise<void> => {
  createAppSideloadPackage(
    options, version, await resolvePreviewConfig(options)
  )(done);
});

function createAppSideloadPackage(
  opts: Options,
  version: string,
  previewCfg?: PreviewConfiguration,
): TaskFunction {
  return series(
    prepareWorkDirectory(),
    copyAppSources(),
    () => updatePayload(previewCfg),
    () => updateManifest(version),
  );
}

function uploadAndRunAppSideloadPackage(opts: Options, device: Device): TaskFunction {
  const outFile = 'reference-app';
  const outDir = resolve('./out');
  const stagingDir = resolve(outDir, 'app');

  return series(
    () => zipPackage({ stagingDir, outDir, outFile, retainStagingDir: true }),
    () => publish({
      host: device.ip,
      password: device.pass,
      outDir,
      outFile,
    }),
  );
}

async function resolveDeviceConfig(opts: Options): Promise<Device> {
  let deviceIp = opts.deviceIp;
  let devicePass = opts.devicePass;

  if (!deviceIp || !devicePass) {
    (await import('dotenv')).config();

    deviceIp = process.env.ROKU_DEV_TARGET;
    devicePass = process.env.DEV_PASSWORD;
  }

  if (!deviceIp || !devicePass) {
    throw new Error(`wasn't able to resolve Roku device configuration`);
  }

  return {
    ip: deviceIp,
    pass: devicePass,
    user: 'rokudev',
    signingKey: opts.deviceSigningKey,
  };
}

async function resolvePreviewConfig(opts: Options): Promise<PreviewConfiguration | undefined> {
  const truexAdResponse = await fetch(opts.truexAdTag, { method: 'GET' });
  const truexAdResponseBody = await truexAdResponse.text();

  const vast = (new XMLParser()).parse(truexAdResponseBody);
  const adConfigUrl = vast.VAST?.Ad?.InLine?.Creatives?.Creative?.reduce(
    (_: any, creative: any) => {
      return creative.CompanionAds?.Companion?.reduce(
        (_: any, companion: any) => companion.StaticResource as string
      );
    }
  );

  return {
    type: defaultPreviewType,
    ad: {
      duration: 30,
      streamFormat: 'iroll',
      adserver: 'no_url_imported_ad',
      adId: `truex-${randomUUID()}`,
      tracking: [],
      streams: [
        {
          mimetype: 'application/json',
          width: 16,
          height: 9,
          bitrate: 0,
          url: adConfigUrl
        }
      ]
    }
  };
}

async function resolveRuntimeParameters(useTestParams: boolean, truexAdTag: string, taDuration?: number): Promise<Record<string, string>> {
  return useTestParams === true
    ? getTestTrueXRuntimeParameters(taDuration)
    : resolveRuntimeParametersFromTrueXAdTag(truexAdTag, taDuration)
  ;
}

async function resolveRuntimeParametersFromTrueXAdTag(truexAdTag: string, taDuration?: number): Promise<Record<string, string>> {
  const truexAdResponse = await fetch(truexAdTag, { method: 'GET' });
  const truexAdResponseBody = await truexAdResponse.text();

  const vast = (new XMLParser()).parse(truexAdResponseBody);
  const adConfigUrl = vast.VAST?.Ad?.InLine?.Creatives?.Creative?.reduce(
    (_: any, creative: any) => {
      return creative.CompanionAds?.Companion?.reduce(
        (_: any, companion: any) => companion.StaticResource as string
      );
    }
  );

  // TODO: add taDuration override

  return Object.fromEntries(
    (new URL(adConfigUrl)).searchParams.entries()
  );
}

function prepareWorkDirectory(): TaskFunction {
  return async (): Promise<void> => {
    logger.info(`Removing ${resolve('./out')}`);
    await fs.rm('./out', { recursive: true, force: true });
    logger.info(`Creating ${resolve('./out/app')}`);
    await fs.mkdir('./out/app', { recursive: true });
  };
}

function copyAppSources(): TaskFunction {
  const dest = './out/app';
  const truexLibraryBasePath = './node_modules/@infillion/truex-engagement-roku'

  return series(
    copyTask({ dest: `${dest}/components`, paths: [ 'components/**/*' ] }),
    copyTask({ dest: `${dest}/source`,     paths: [ 'source/**/*' ] }),
    copyTask({ dest: `${dest}/libs`,       paths: [ 'libs/**/*' ] }),
    copyTask({ dest,                       paths: [ 'manifest' ] }),
    // truex components import
    // copyTask({
    //   dest: `${dest}/components/infillion`,
    //   paths: [ resolve(truexLibraryBasePath, 'components/infillion/**/*') ],
    // }),
    // copyTask({
    //   dest: `${dest}/res`,
    //   paths: [ resolve(truexLibraryBasePath, 'res/**/*') ]
    // }),
  );
}

async function updatePayload(previewCfg: PreviewConfiguration | undefined): Promise<void> {
  const payload = {
    example: previewCfg,
  };

  await fs.writeFile(
    resolve('./out/app/source/payload.json'),
    JSON.stringify(payload, undefined, 2),
  );
}

async function updateManifest(version: string): Promise<void> {
  const parts = version.split('.');
  const major = parts[0] ?? 0;
  const minor = parts[1] ?? 0;
  const patch = parts[2] ?? 0;

  await fs.writeFile(
    `./out/app/manifest`,
    stripIndent`
      title=Infillion // BlueScript Engagement // Reference App
      subtitle=Sample App
      major_version=${major}
      minor_version=${minor}
      build_version=${patch}
      splash_color=#404040

      ui_resolutions=fhd
      bs_libs_required=roku_ads_lib

      # This enables your application to deep link into content without re-launching your channel.
      supports_input_launch=1
      rsg_version=1.2

      # instant resume
      # sdk_instant_resume=1
      # run_as_process=1
    `
  );
}

function getTestTrueXRuntimeParameters(taDuration?: number): Record<string, string> {
  return {
    ivc: (new URLSearchParams({
      aa: '30',
      bd: '3',
      bgv: 'http://media.truex.com/video_assets/2017-11-22/8b455dc7-c30d-4267-9caa-f3f25c5a41a8_large.mp4',
      f: '',
      ib: 'http://media.truex.com/image_assets/2017-10-26/77c77cfa-2201-456d-830d-ca2d562cb970.png',
      ix: '340',
      iy: '364',
      n: '',
      p: 'bid_info=bid_info_string&campaign_id=9668&creative_id=8483&currency_amount=1&impression_signature=5bd87addc98a34fd673153f2cd8e448604ca5dad65cc630152cf9d18199200b3&impression_timestamp=1673663490.9821064&internal_referring_source=P5T-leJhQCqxxybPihek0Q&ip=24.186.99.179&multivariate%5BBEP-3725-2-key%5D=BEP-3725-control-2&multivariate%5BBEP-3725-key%5D=BEP-3725-T6-1&multivariate%5BFAP-460%5D=oldTT&multivariate%5Bctv_footer_test%5D=control&multivariate%5Bctv_footer_test_22105de992284775a56f28ca6dac16c667e73cd0%5D=T0&multivariate%5Bctv_footer_test_74fca63c733f098340b0a70489035d683024440d%5D=T0&multivariate%5Bctv_relevance_enabled%5D=T0&multivariate%5Bctv_xtended_view%5D=T0&multivariate%5Bdv_cohort%5D=3&multivariate%5Btruex_first_experiment%5D=control&multivariate%5Btvml_cc_test%5D=control&multivariate%5BtvosUnifyUIExperiment%5D=T3&network_user_id=hulu_asodijfoaajsdiofj&optimized=true&placement_hash=50f0b0944f3a826e6d73c8895cb868fb2af0171c&session_id=I8H6PeCRTfeHgF4lcJeTvQ&stream_id=h8pubzpzRgmoM09V1zGioQ&vault=vault_string',
      pos: 'midroll',
      product: 'sponsored_ad_break',
      resume: 'false',
      s: 'http://qa-measure.truex.com',
      sec: `${taDuration ?? 30}`,
      showskipcard: 'false',
      sk: 'http://media.truex.com/image_assets/2017-06-22/75fd3fa0-f9da-4e57-b2cb-9505f801d867.jpg',
      vo: '',
      wb: 'http://media.truex.com/image_assets/2017-10-26/7c74b4cb-edcf-489f-9d86-15af40f367a5.png',
      wx: '632',
      wy: '364',
      ivfvva: '1',
      iv_geo_dma: '511',
      iv_geo_country: 'US',
      iv_geo_city: 'Ashburn',
      iv_geo_state: 'VA',
      iv_geo_zip: '20149',
      iv_geo_lat: '39.0469',
      iv_geo_lon: '-77.4903'
    })).toString(),
    cb: `${Date.now()}`,
  };
};

export type Device = {
  ip: string,
  pass: string,
  user: string,
  signingKey?: string,
};

export type PreviewConfiguration = {
  type: 'raf-ssai-sponsored-ad-break',
  ad: RAFAd,
};

export type RAFAd = {
  duration: number,
  streamFormat: 'iroll',
  adserver: string,
  tracking: RAFTracking[],
  streams: RAFAdStream[],
  companionAds?: RAFCompanionAd[],
  adId?: string,
  adTitle?: string,
  advertiser?: string,
  creativeId?: string,
  creativeAdId?: string,
};

export type RAFAdStream = {
  url: string,
  bitrate: number,
  width: number,
  height: number,
  mimetype: string,
  id?: string,
  provider?: string,
};

export type RAFCompanionAd = {
  url: string,
  width: number,
  height: number,
  mimetype: string,
  tracking: RAFTracking[],
  provider?: string,
};

export type RAFTracking = {
  event: string,
  url: string,
  triggered: boolean,
  time?: number,
};