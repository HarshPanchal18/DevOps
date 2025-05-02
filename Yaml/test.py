import yaml

with open("first.yaml") as file:
    try:
        print(yaml.safe_load(file))
    except yaml.YAMLError as ye:
        print(ye)