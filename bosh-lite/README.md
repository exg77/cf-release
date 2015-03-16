# Deploying CF on bosh-lite

## Minimum requirements

The machine this worked on was running with 8GB of ram. We recommend using 16GB or more for a much better reliability and performance.

## Prepare and target the bosh lite director

Make sure you have successfully installed and started the bosh-lite vm. This guide will assume default settings and setup recommended at:
https://github.com/cloudfoundry/bosh-lite/blob/master/README.md

A Bosh lite director must be available and targeted by the `bosh` command line executable.

##Quick start for a demo of CF

Assuming the above bosh director preparation and current directory to be a checkout of `cloudfoundry/cf-release` repo.

```
./bosh-lite/provision_latest_stable.sh
```

##Step by step deploy to make and test dev releases

### Upload a cf-compatible bosh-lite stemcell

Bosh team provides warden stemcells for use with bosh lite.

```
curl -L https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent -o latest-bosh-lite-stemcell.tgz
bosh upload stemcell latest-bosh-lite-stemcell.tgz
```

### Create and upload a cf release to the bosh-lite director

If you'd like to deploy the currently checked out git commit 

```
  bosh create release
  bosh upload release
```

### Prepare a deployment manifest using a provided script

```
./bosh-lite/make_manifest
```

### Deploy using a generated manifest

CF Runtime team uses a manifest generator to test CloudFoundry with basic default settings.

```
bosh -d ./bosh-lite/manifests/cf-manifest.yml deploy
```

### Confirm your cf is running and is able to deploy apps

There are 4 checks that confirm your CF is running correctly
1. /v2/info API endpoint responds
1. One simple app pushes successfully. This way you can also explore CF via this app (make requests, tail logs, etc)
1. Run smoke tests suite included as a bosh errand to make sure an app can go through a full lifecycle
1. An acceptance test suite included as a bosh errand completes successfully


Test 1
Validate API endpoint is available

```
curl api.10.244.0.34.xip.io/v2/info
```

Test 2
Use cf cli(available at https://github.com/cloudfoundry/cli) to push one of simple apps available in `src/acceptance-tests/assets`. This 

```
cd src/acceptance-tests/assets/ruby_simple
#login into a an account, space, org
cf logout
cf api api.10.244.0.34.xip.io --skip-ssl-validation
cf auth admin admin
cf co test1
cf target -o test1
cf create-space test1
cf target -o test1 -s test1
cf push test_app
#Observe deployment for any errors or warnings
```

Test 3

```
bosh run errand acceptance_tests
```
