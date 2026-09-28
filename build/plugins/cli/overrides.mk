$(PLUGIN_HEADER)

vips_DEPS := $(filter-out librsvg pango,$(vips_DEPS)) libpng expat fftw libraw
vips_MESON_OPTS := $(filter-out -Dfftw=disabled -Draw=disabled -Dppm=false -Danalyze=false -Dradiance=false,$(vips_MESON_OPTS))
vips_MESON_OPTS += -Dcplusplus=false -Dfftw=enabled -Dheif=enabled -Dpangocairo=disabled -Drsvg=disabled -Draw=enabled -Dppm=true -Danalyze=true -Dradiance=true

define vips_BUILD
    $(eval export CFLAGS += -O3)
    $(eval export CXXFLAGS += -O3)

    $(MXE_MESON_WRAPPER) \
        --default-library=static \
        -Ddeprecated=false \
        -Dexamples=false \
        -Dintrospection=disabled \
        $(vips_MESON_OPTS) \
        '$(SOURCE_DIR)' \
        '$(BUILD_DIR)'

    $(MXE_NINJA) -C '$(BUILD_DIR)' -j '$(JOBS)' install
endef
