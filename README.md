# baidunetdisk-syn-tools
Automatically package some local folders and upload them to Baidu Netdisk

For obtaining the token, please refer to the [official documentation](https://pan.baidu.com/union/doc/ol0rsap9s).
Note: It's recommended to choose the *Device Code Mode* for the authorization process.

Once you have obtained the token, replace it in the script below, and you'll be able to use the script.

To run the script:
```shell
bash upload.sh
```

Then, just wait for a moment.When the script returns a JSON string with an error code of 0, it indicates that the script has run successfully, meaning that the file backup was successful.You will be able to find this compressed file on Baidu Netdisk.
