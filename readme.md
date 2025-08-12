# VBB GTFS-Flex feed

**Generate a [GTFS-Flex v2](https://gtfs.org/community/extensions/flex/) feed that augments [VBB](https://en.wikipedia.org/wiki/Verkehrsverbund_Berlin-Brandenburg)'s [official GTFS Schedule feed](https://unternehmen.vbb.de/digitale-services/datensaetze/).**

[![CC0-licensed](https://img.shields.io/github/license/public-transport/vbb-gtfs-flex.svg)](LICENSE)

It adds the following demand-responsive lines:

- [RufBus lines R476, R477 & R478 in Angermünde](https://uvg-online.com/rufbus-angermuende/)
- [RufBus lines R487 & R488 in Gartz](https://uvg-online.com/rufbus-gartz/)


## Obtaining the feed

The built GTFS-Flex feed is published via GitHub Pages:

```shell
wget 'https://public-transport.github.io/vbb-gtfs-flex/vbb-flex.gtfs.zip'
```


## Building the feed

You need [`qsv`](https://github.com/jqnatividad/qsv), which you can download from [its latest release](https://github.com/jqnatividad/qsv/releases/latest).

```shell
git clone https://github.com/public-transport/vbb-gtfs-flex.git
cd gtfs-flex
./build.sh
```
