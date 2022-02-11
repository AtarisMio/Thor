# Thor

inspired by [cnk3x/xunlei](https://github.com/cnk3x/xunlei) and [Infinity-Server/docker_image_set](https://github.com/Infinity-Server/docker_image_set)

## What is Thor

Thor is an docker mod of `thunder`

## How can I use it

1. run `docker pull ataris/Thor`
2. make sure your real path for download exists. for example `/downloads`
2. run `docker run -d --name Thor -p 5050:5050 -v /downloads:/downloads ataris/Thor`
3. open browser to `localhost:5050`, and enjoy it.

## I want to compile it by myself (for arm or else)

1. you should prepare a `xunlei.spk` by you self.
2. then run `docker build . -t xxx`