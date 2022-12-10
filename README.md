### Build this docker image

Dockerfiles are available for the following dev environments (Use tasks.json for commands)

- ARM Cross Toolchain: GCC 10.3.1 arm-none-eabi
- ARM Cross Toolchain: GCC 11.3 arm-none-eabi


### Run container instance

docker run --rm -it stm32_dev

Recommended to use VSCode with `Dev Containers` installed. See `examples` folder for json file.

### Github Docker registry

To access this image you must authenticate to the [github registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry) by creating a `Personal Access Token` and __exporting it to a variable in your environment__. Recommend putting it in ~/.bashrc.

Pull the image using the [docker command](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#pulling-container-images).

For example:

```
docker push ghcr.io/<USER>/stm32_dev:10.3-2021.10
docker pull ghcr.io/<USER>/stm32_dev:10.3-2021.10
```

### Debugging the target within VScode

Using USB between host/guest with containers is problematic. Much easier is to use TCP.
i.e. install JLink Remote Server on the host and listen for the connection from the debugger.
For example:


- Guest

    - JLinkGDBServer command:

    ```
    JLinkGDBServer -if swd -device STM32F427VG -select ip=<host>
    ```

    - CortexDebug (VSCode), add this to launch.json:

    ```
    "servertype": "external",
    "gdbTarget": "<host>:2331",
    ```

### X11 Server (experimental)

Using JLink tools requires X11 Server installed on the host (it has pop-up window options)

This should be already installed on a Linux host.

For MacOS hosts you can install [XQuartz](https://www.xquartz.org/)

See instructions here - https://gist.github.com/sorny/969fe55d85c9b0035b0109a31cbcb088

Don't forget to run the xhost command (put it in ~/.bashrc on the host)

```
xhost +
```

/opt/JLink_Linux_V782b_x86_64/JLinkExe -NoGui 1