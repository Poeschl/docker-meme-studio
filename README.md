# 🕸️ Archived
This repository is archived and not maintained anymore.
As replacement, I suggest to use the online meme studio at https://www.meme-studio.io.

----

# Dockerized Meme Studio

The last days I found the [Meme Studio](https://github.com/viclafouch/meme-studio) application from @viclafouch and I wanted a self-hosted version of it.
Since I use only container images for my self-hosted services, this repository automatically builds one for me.

## Usage

The image is only available with the `latest` tag. It can be used with podman like so `podman run --rm -p 8080:3000 ghcr.io/poeschl/meme-studio:latest`.
This command will make the meme-studio available on your current machine at port `8080`.

For a hosted variant a `docker-compose.yaml` is included, but basically just add a service with the image and start up your docker or podman compose.

## Thanks

* @viclafouch for the really nice Meme Studio
