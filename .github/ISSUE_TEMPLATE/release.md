# openslide-bin release process

- [ ] Update software versions, submit PR
- [ ] Land PR
- [ ] Create and push signed tag
- [ ] Verify that CI creates a [GitHub release](https://github.com/openslide/openslide-bin/releases/) with artifacts
- [ ] Update website: `_data/releases.yaml`, maybe `_includes/news.md`
- [ ] Possibly send mail to -announce and -users
- [ ] Update `WINBUILD_RELEASE` in [OpenSlide Python CI](https://github.com/openslide/openslide-python/blob/main/.github/workflows/python.yml)
