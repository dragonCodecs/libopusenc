project(
	'libopusenc',
	'c',
	version: '0.2.1',
	license: 'BSD-3-Clause',
	default_options: [
		'warning_level=3',
		'c_std=gnu99',
	]
)

op_lt_current = 4
op_lt_revision = 2
op_lt_age = 4

library_version_major = op_lt_current - op_lt_age
library_version_minor = op_lt_age
library_version_patch = op_lt_revision
library_version = '@0@.@1@.@2@'.format(
	library_version_major,
	library_version_minor,
	library_version_patch,
)

compiler = meson.get_compiler('c')

config_h_data = configuration_data()

opusenc_args = []

add_project_arguments(
	compiler.get_supported_arguments(
		'-Wno-sign-compare',
		'-Wno-parentheses',
		'-Wno-long-long',
		# MSVC
		'-wd4267',
		'-wd4244',
		'-wd4996',
		'-wd4101',
		'-wd4018',
	),
	language: 'c'
)

add_project_arguments(
	'-DHAVE_CONFIG_H',
	'-DRANDOM_PREFIX=libopusenc',
	'-DOUTSIDE_SPEEX',
	'-DOPE_BUILD',
	language: 'c'
)

config_h_data.set_quoted('PACKAGE_NAME', meson.project_name())
config_h_data.set_quoted('PACKAGE_VERSION', meson.project_version())

# We need WINNT>=0x501 (WindowsXP) for getaddrinfo/freeaddrinfo.
# It's okay to define this even when HTTP support is disabled, as it only
#  affects header declarations, not linking (unless we actually use some
#  XP-only functions).
if target_machine.system() == 'windows'
	add_project_arguments(
		'-DWIN32',
		'-D_WIN32_WINNT=0x501',
		language: 'c'
	)
endif

opus = dependency('opus', version: '>= 1.1', required: true)

m = compiler.find_library('m', required: false)

opusenc_deps = [
	opus,
	m,
]

config_h_data.set10('RESAMPLE_FULL_SINC_TABLE', true)

config_h = configure_file(
	output: 'config.h',
	configuration: config_h_data
)

opusenc_headers = files(
	'include/opusenc.h',
)

opusenc_includes = include_directories('.', 'include')

opusenc_include_dir = 'opus'

install_headers(
	opusenc_headers,
	subdir: opusenc_include_dir,
)

opusenc_srcs = files(
	'src/ogg_packer.c',
	'src/opus_header.c',
	'src/opusenc.c',
	'src/picture.c',
	'src/resample.c',
	'src/unicode_support.c',
)

opusenc_extra_srcs = files(
	'src/arch.h',
	'src/ogg_packer.h',
	'src/opus_header.h',
	'src/picture.h',
	'src/resample_sse.h',
	'src/speex_resampler.h',
	'src/unicode_support.h',
)

opus_link_args = []

opus_link_args += compiler.get_supported_link_arguments(
	'-no-undefined'
)

if get_option('default_library') == 'static'
	opusenc_lib = static_library(
		'opusenc',
		opusenc_srcs + config_h,
		c_args: opusenc_args,
		include_directories: opusenc_includes,
		extra_files: opusenc_extra_srcs,
		dependencies: opusenc_deps,
		link_args: opus_link_args,
		gnu_symbol_visibility: 'hidden',
		install: true
	)
else
	opusenc_args += [
		'-DDLL_EXPORT'
	]

	opusenc_lib = shared_library(
		'opusenc',
		opusenc_srcs + config_h,
		c_args: opusenc_args,
		include_directories: opusenc_includes,
		extra_files: opusenc_extra_srcs,
		dependencies: opusenc_deps,
		link_args: opus_link_args,
		version: library_version,
		gnu_symbol_visibility: 'hidden',
		install: true
	)
endif

libopusenc_dep = declare_dependency(
	link_with: opusenc_lib,
	dependencies: opusenc_deps,
	include_directories: opusenc_includes,
)

meson.override_dependency('libopusenc', libopusenc_dep)

if get_option('examples')
	opusenc_example_srcs = files(
		'examples/opusenc_example.c',
	)

	opusenc_example = executable(
		'opusenc_example',
		opusenc_example_srcs,
		dependencies: libopusenc_dep,
	)
endif

pkg = import('pkgconfig')
pkg.generate(
	opusenc_lib,
	name: 'libopusenc',
	description: 'High-level Opus encoding library',
	url: 'https://opus-codec.org/',
	subdirs: opusenc_include_dir,
)

if get_option('doc')
	doxygen = find_program('doxygen', required: false, disabler: true)
	dot = find_program('dot', required: false, disabler: true)

	cdata = configuration_data()
	cdata.set('PACKAGE_NAME', meson.project_name())
	cdata.set('PACKAGE_VERSION', meson.project_version())
	if dot.found()
		cdata.set('HAVE_DOT', 'YES')
	else
		cdata.set('HAVE_DOT', 'NO')
	endif
	cdata.set('top_srcdir', meson.current_source_dir())
	
	doxyfile = configure_file(
		input: 'doc/Doxyfile.in',
		output: 'Doxyfile',
		configuration: cdata,
	)

	dist_doc = get_option('datadir') / 'doc' / meson.project_name()

	docs = custom_target(
		'docs',
		input: doxyfile,
		output: 'html',
		command: [doxygen, doxyfile],
		console: true,
		install: true,
		install_dir: dist_doc,
	)
endif

summary({
	'Library version': library_version,
})
