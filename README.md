
# V3-scale-testbench

## Steps

### Aws setup

Create the container registry in AWS. There should be one created already.

### Build docker image locally and upload to Github.

Go to the `v3` repo and run:

```
$ docker build -t example .
```

This will create a local docker image with name `example`.

### Generate account keys

```
$ ./setup-accounts.sh
```

### Deploy the infrastructure

```
$ terraform init
$ terraform apply
```

TODO:
- docker image upload.
