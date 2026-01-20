# Overlays (dev)

- In `dev` deployment, we only want to increase the replicas from 1 to 2. You can see **we only define the changes, not other things**.

  Kustomize will check the base deployment file and compare it and patch the changes accordingly. That's the beauty of Kustomize.

- In dev, we need the service with a `nodeport`. So we will create an overlay with the type `Nodeport`.
