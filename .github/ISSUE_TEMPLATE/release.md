# openslide-bin release process

- [ ] Run [workflow](https://github.com/openslide/openslide-bin/actions/workflows/update-check.yml) to check for updates
- [ ] Merge any resulting PR; perform any needed manual updates reported by the workflow
- [ ] Create and push signed tag
- [ ] Verify that CI creates a [GitHub release](https://github.com/openslide/openslide-bin/releases/) with artifacts
- [ ] Update website: `_data/releases.yaml`, maybe `_includes/news.md`
- [ ] Possibly send mail to -announce and -users
- [ ] Possibly post to [forum.image.sc](https://forum.image.sc/c/announcements/10)
- [ ] Update `BIN_RELEASE` in [OpenSlide Python CI](https://github.com/openslide/openslide-python/blob/main/.github/workflows/python.yml)
