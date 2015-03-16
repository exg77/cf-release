# Deploying CF on bosh-lite

## Minimum requirements

The smallest laptop this worked on was running with at 8GB of ram. We recommend using 16GB or more for a much better reliability and performance.

### Target the bosh-lite director

Make sure you have successfully installed and started the bosh-lite vm. This guide will assume default settings and setup recommended at:
https://github.com/cloudfoundry/bosh-lite/blob/master/README.md

```
bosh target 192.168.50.4 lite
```

### Clone the cf-release repository
```
git clone https://github.com/cloudfoundry/cf-release/
cd cf-release
```

### create and upload the release to the bosh-lite director

if you'd like to deploy the currently checked out git commit 

```
  bosh -t lite create release
  bosh -t lite upload release
```

### Prepare a deployment manifest using a provided script

```
./bosh-lite/make_manifest
```

### Deploy using a generated manifest

The generated manifest instructs the director to deploy the 'latest' uploaded cf release.

```
bosh -t lite -d ./bosh-lite/manifests/cf-manifest.yml deploy
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
bosh -t lite run errand acceptance_tests
```
