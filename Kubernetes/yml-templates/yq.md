# YQ

| Usage | Command |
|--|--|
| Read a value from YAML | `yq '.metadata.name' file.yaml` |
| Update value in-place | `yq -i '.spec.replicas=2' file.yaml` |
| Delete a field | `yq -i 'del(.metadata.annotations)' file.yaml` |
| Convert YAML to JSON | `yq -ojson file.yaml` |
| Convert JSON to YAML | `yq -Poy file.yaml` |
| Pretty print YAML | `yq -P file.yaml` |
| Iterate over list | `yq '.items[]' file.yaml` |
| Recursive search | `yq '.. \| select(has("args"))' file.yaml` |
| Filter entries | `yq '.select(.kind == "Deployment")' file.yaml` |
| Multiple updates | `yq -i '.a.b[0].c="foo" \| .x.y.z="bar"' file.yaml` |
| Find and update | `yq -i '(.[] \| select(.name == "foo") \| .address) = "12 cat st"' file.yaml` |
| Merge multiple YAMLs | `yq -n 'load("file1.yaml") * load("file2.yaml")` |
