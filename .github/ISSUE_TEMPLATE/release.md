# openslide-winbuild release process

- [ ] Update software versions and push
- [ ] If releasing updated Windows binaries for an *existing* OpenSlide release, start wintest CI builds against the corresponding OpenSlide tag and wait for them to finish
- [ ] Start a winbuild-release build in CI and wait for it to finish
- [ ] Download release artifacts from the `zip` links on the build's status page
- [ ] Test binaries with Wine
- [ ] Create and push signed tag
- [ ] Attach OpenSlide and OpenSlide Java versions to [GitHub release](https://github.com/openslide/openslide-winbuild/releases/new); upload release artifacts
- [ ] Update website: `_data/releases.yaml`, maybe `_includes/news.markdown`
- [ ] Possibly send mail to -announce and -users
