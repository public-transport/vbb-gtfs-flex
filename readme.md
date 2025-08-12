# VBB GTFS-Flex feed

**Generate a [GTFS-Flex v2](https://gtfs.org/community/extensions/flex/) feed that augments [VBB](https://en.wikipedia.org/wiki/Verkehrsverbund_Berlin-Brandenburg)'s [official GTFS Schedule feed](https://unternehmen.vbb.de/digitale-services/datensaetze/).**

[![CC0-licensed](https://img.shields.io/github/license/bbnavi/gtfs-flex.svg)](LICENSE)

It adds the following demand-responsive lines:

- [RufBus lines R476, R477 & R478 in Angermünde](https://uvg-online.com/rufbus-angermuende/)
- [RufBus lines R487 & R488 in Gartz](https://uvg-online.com/rufbus-gartz/)


## Obtaining the feed

If you want to use this feed, download it from [the respective `opendata.bbnavi.de` page](https://opendata.bbnavi.de/vbb-gtfs-flex/index.html):

```shell
wget 'https://opendata.bbnavi.de/vbb-gtfs-flex/gtfs-flex.zip'
```


## Building the feed

You need [`qsv`](https://github.com/jqnatividad/qsv), which you can download from [its latest release](https://github.com/jqnatividad/qsv/releases/latest).

```shell
git clone https://github.com/bbnavi/gtfs-flex.git
cd gtfs-flex
./build.sh
```
