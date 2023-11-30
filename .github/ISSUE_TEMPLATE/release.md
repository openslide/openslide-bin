# openslide-bin release process

- [ ] If there's a new OpenSlide release, remove `dev_deps` condition from any subprojects used by the new release
- [ ] Run [workflow](https://github.com/openslide/openslide-bin/actions/workflows/update-check.yml) to check for updates
- [ ] Merge any resulting PR; perform any needed manual updates reported by the workflow
- [ ] Submit PR to update `CHANGELOG.md` and `_PROJECT_VERSION`
- [ ] Land PR
- [ ] Create and push signed tag
- [ ] Find the [workflow run](https://github.com/openslide/openslide-bin/actions/workflows/release.yml) for the tag
  - [ ] Once the build finishes, approve deployment to PyPI
- [ ] Verify that CI creates a [PyPI release](https://pypi.org/p/openslide-bin) with a description, source tarball, and wheels
- [ ] Verify that CI creates a [GitHub release](https://github.com/openslide/openslide-bin/releases/) with release notes, software versions, and artifacts
- [ ] Update website: `_data/releases.yaml`, maybe `_includes/news.md`
- [ ] Possibly send mail to -announce and -users
- [ ] Possibly post to [forum.image.sc](https://forum.image.sc/c/announcements/10)
- [ ] Update `BIN_RELEASE` in [OpenSlide Python CI](https://github.com/openslide/openslide-python/blob/main/.github/workflows/python.yml)
