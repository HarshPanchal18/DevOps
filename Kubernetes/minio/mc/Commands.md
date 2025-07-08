# Some of the useful commands for MinIO Client (mc)

- Create a new alias for tenant.

    ```bash
    mc alias set myminio-tenant http://minio.example.com:9000 access-key secret-key
    ```

- List all buckets of a tenant.

    ```bash
    mc ls myminio-tenant
    ```

- Make a new bucket.

    ```bash
    mc mb myminio-tenant/mybucket-0
    ```

- Remove a bucket from tenant.

    ```bash
    mc rb myminio-tenant/mybucket-0
    ```

- List all objects in a bucket.

    ```bash
    mc ls myminio-tenant/mybucket-0
    ```

- Copy an object to a bucket.

    ```bash
    mc cp /path/to/local/file.txt myminio-tenant/mybucket-0
    ```

- Copy an object from a bucket to local.

    ```bash
    mc cp myminio-tenant/mybucket-0/file.txt /path/to/local/file.txt
    ```

- Remove an object from a bucket.

    ```bash
    mc rm myminio-tenant/mybucket-0/file.txt
    ```

- Sync a local directory to a bucket.

    ```bash
    mc mirror /path/to/local/dir myminio-tenant/mybucket-0
    ```

- Sync a bucket to a local directory.

    ```bash
    mc mirror myminio-tenant/mybucket-0 /path/to/local/dir
    ```

- Set bucket policy.

    ```bash
    mc policy set public myminio-tenant/mybucket-0
    ```

- Get bucket policy.

    ```bash
    mc policy info myminio-tenant/mybucket-0
    ```

- Set bucket lifecycle policy.

    ```bash
    mc ilm import myminio-tenant/mybucket-0 /path/to/lifecycle.json
    ```

- Get bucket lifecycle policy.

    ```bash
    mc ilm info myminio-tenant/mybucket-0
    ```

- List all aliases.

    ```bash
    mc alias ls
    ```

- Remove an alias.

    ```bash
    mc alias rm myminio-tenant
    ```

- Show help for a specific command.

    ```bash
    mc help <command>
    ```

- Show help for all commands.

    ```bash
    mc --help
    ```

- Download file from bucket to local.

    ```bash
    mc get myminio-tenant/mybucket-0/file.txt
    ```

- Upload file from local to bucket.

    ```bash
    mc put /path/to/local/file.txt myminio-tenant/mybucket-0
    ```

- List all objects with detailed information.

    ```bash
    mc ls --recursive myminio-tenant/mybucket-0
    ```

- Check the health of MinIO server.

    ```bash
    mc admin info myminio-tenant
    ```

- Set bucket versioning.

    ```bash
    mc version enable myminio-tenant/mybucket-0
    ```

- Get bucket versioning status.

    ```bash
    mc version info myminio-tenant/mybucket-0
    ```

- Remove all objects in a bucket.

    ```bash
    mc rm --recursive myminio-tenant/mybucket-0
        # --bypass - Allows removing an object held under GOVERNANCE object locking.
        # --version-id - Operate on the specified object version.
        # --versions - Operate on all object versions that exist in the bucket.
    ```

- Set bucket encryption.

    ```bash
    mc encrypt set myminio-tenant/mybucket-0 --sse
    ```

- Get bucket encryption status.

    ```bash
    mc encrypt info myminio-tenant/mybucket-0
    ```

- List all users.

    ```bash
    mc admin user list myminio-tenant
    ```

- Create a new user.

    ```bash
    mc admin user add myminio-tenant newuser newpassword
    ```

- Synchronize content from a local FS to the data bucket.

    ```bash
    mc mirror --watch /path/to/local/dir myminio-tenant/mybucket-0
        # --exclude - Exclude object(s) in the SOURCE path.
        # --exclude-bucket - Exclude bucket(s) in the SOURCE path.
        # --remove - Remove object(s) on the TARGET that do not exist on SOURCE.
        # --retry - Retry each errored object.
        # --skip-errors - Skip any object(s) that produce errors.
        # --summary - On completion, o/p a summary of the data that was synchronized.
    ```

- Check liveness on a target.

    ```bash
    mc ping myminio-tenant --count 5
        # --error-count - Specify a number of errors to receive before exiting.
        # --exit - Exit after the 1st successful check.
        # --interval - seconds to wait between requests.
    ```

- Check if a cluster is down for the maintenance.

    ```bash
    mc ready myminio-tenant --maintenance
    ```

- Replicate buckets from `myminio-tenant/bucket-0` to `new-tenant/bucket-0` with rules.

    ```bash
    mc replicate add myminio-tenant/bucket-0 --remote-bucket new-tenant/bucket-0 --replicate "delete,delete-marker,existing-objects"
    ```

- Update replicate rules.

    ```bash
    mc replicate update --id <rule-id> --replicate "delete,existing-objects" myminio-tenant/bucket-0
    ```

- Export replication rule into `json`.

    ```bash
    mc replicate export myminio-tenant/bucket-0 > bucket-replication.json
    ```

    Similar output:

    ```json
    {"Rules":[{
            "ID":"d1losauod1es4kj7thj0",
            "Status":"Enabled",
            "Priority":0,
            "DeleteMarkerReplication":{"Status":"Disabled"},
            "DeleteReplication":{"Status":"Enabled"},
            "Destination":{"Bucket":"arn:minio:replication::705d9b7d-085c-4b34-a4c1-cff5efbfdd7a:bucket-0"},
            "Filter":{"And":{},"Tag":{}},
            "SourceSelectionCriteria":{
                "ReplicaModifications":{
                    "Status":"Disabled"
                }
            },
            "ExistingObjectReplication":{
                "Status":"Enabled"
            }
        }],
        "Role":""
    }
    ```

- Import replication rule from `json`.

    ```bash
    mc replicate import myminio-tenant/bucket-0 < bucket-replication.json
    ```

- Attach a tag to the bucket.

    ```bash
    mc tag set myminio-tenant/bucket-0 "tag=value&tag1=value1"
    mc tag list myminio-tenant/bucket-0
    ```

- Tree view of a tenant.

    ```bash
    mc tree myminio-tenant
        # --files - Include files in the object or directory.
    ```

- Undo operation. e.g. reverts the most recent PUT for `file.zip` in bucket, reverting to the previous object version.

    ```bash
    mc undo myminio-tenant/bucket-0/file.zip --action "PUT"
    ```

- Restoring a file.

    ```bash
    mc undo myminio-tenant/bucket-0/images --recursive --action "DELETE"
        # --force
        # --dry-run
        # --last N - Do reverse N operation
    ```

- Watch an object.

    ```bash
    mc watch --recursive myminio-tenant/bucket-0
    ```
