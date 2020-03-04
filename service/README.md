[issue-template]: ../../issues/new?template=BUG_REPORT.md
[feature-template]: ../../issues/new?template=FEATURE_REQUEST.md

<a href="https://singularitynet.io/">
<img align="right" src="./docs/assets/logo/singularityNETblue.png" alt="drawing" width="160"/>
</a>

# Causality Detection

> Repository for the causality detection service on the SingularityNET.

[![Github Issues](https://img.shields.io/github/issues-raw/singnet/causality-detection.svg?style=popover)](https://github.com/singnet/causality-detection/issues)
[![Pending Pull-Requests](https://img.shields.io/github/issues-pr-raw/singnet/causality-detection.svg?style=popover)](https://github.com/singnet/causality-detection/pulls)
[![GitHub License](	https://img.shields.io/github/license/singnet/dnn-model-services.svg?style=popover)](https://github.com/singnet/causality-detection/blob/master/LICENSE)
[![CircleCI](https://circleci.com/gh/singnet/causality-detection.svg?style=svg)](https://circleci.com/gh/singnet/causality-detection)

This service uses convolutional neural networks to increase the resolution of an image by reconstructing rather than simply resizing it. The images are upscaled by a factor of 4.

The original code is written in R and has been integrated into the SingularityNET using Python 3.6.

Refer to:
- [The User's Guide](https://singnet.github.io/causality-detection/): for information about how to use this code as a SingularityNET service;
- [The Original Repository](https://github.com/xinntao/ESRGAN): for up-to-date information on [xinntao](https://github.com/xinntao) implementation of this code.
- [SingularityNET Wiki](https://github.com/singnet/wiki): for information and tutorials on how to use the SingularityNET and its services.

## Contributing and Reporting Issues

Please read our [guidelines](https://github.com/singnet/wiki/blob/master/guidelines/CONTRIBUTING.md#submitting-an-issue) before submitting an issue. If your issue is a bug, please use the bug template pre-populated [here][issue-template]. For feature requests and queries you can use [this template][feature-template].

## Authors

* **Nejc Znidar** - *Service Developer* - [SingularityNET](https://www.singularitynet.io)
* **Ramon Durães** - *Service Maintainer* - [SingularityNET](https://www.singularitynet.io)

## License

The original repository is licensed under the Apache License v2.0. See the [LICENSE](LICENSE) file for details. 