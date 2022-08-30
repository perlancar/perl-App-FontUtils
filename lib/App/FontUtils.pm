package App::FontUtils;

use 5.010001;
use strict;
use warnings;
use Log::ger;

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

my %argspec0_ttf_file = (
    ttf_file => {
        schema => ['filename*'],
        'x.completion' => ['filename', {file_ext_filter=>['ttf','TTF']}],
        req => 1,
        pos => 0,
    },
);

my %argspec0_otf_file = (
    otf_file => {
        schema => ['filename*'],
        'x.completion' => ['filename', {file_ext_filter=>['otf','OTF']}],
        req => 1,
        pos => 0,
    },
);

my %argspec1opt_ttf_file = (
    ttf_file => {
        schema => ['filename*'],
        'x.completion' => ['filename', {file_ext_filter=>['ttf','TTF']}],
        pos => 1,
    },
);

my %argspec1opt_otf_file = (
    otf_file => {
        schema => ['filename*'],
        'x.completion' => ['filename', {file_ext_filter=>['otf','OTF']}],
        pos => 1,
    },
);

our %argspecopt_overwrite = (
    overwrite => {
        schema => 'bool*',
        cmdline_aliases => {O=>{}},
    },
);

$SPEC{ttf2otf} = {
    v => 1.1,
    summary => 'Convert TTF to OTF',
    description => <<'_',

This program is a shortcut wrapper for <prog:fontforge>. This command:

    % ttf2otf foo.ttf

is equivalent to:

    % fontforge -lang=ff -c 'Open($1); Generate($2); Close();' foo.ttf foo.otf

_
    args => {
        %argspec0_ttf_file,
        %argspec1opt_otf_file,
        %argspecopt_overwrite,
    },
    deps => {
        prog => 'fontforge',
    },
    links => [
        {url => 'prog:otf2ttf'},
    ],
};
sub ttf2otf {
    require IPC::System::Options;

    my %args = @_;

    my $ttf_file = $args{ttf_file};
    -f $ttf_file or return [500, "File '$ttf_file' does not exist or not a file"];

    my $otf_file = $args{otf_file};
    unless (defined $otf_file) {
        ($otf_file = $ttf_file) =~ s/\.ttf\z/.otf/i;
    }
    $otf_file eq $ttf_file and return [412, "Please specify a different name for the output OTF file"];
    ((-f $otf_file) && !$args{overwrite}) and return [412, "OTF file '$otf_file' already exists, please specify another output name or use --overwrite"];

    IPC::System::Options::system(
        {log=>1, die=>1},
        "fontforge", "-lang=ff", "-c", 'Open($1); Generate($2); Close();', $ttf_file, $otf_file,
    );
    [200];
}

$SPEC{otf2ttf} = {
    v => 1.1,
    summary => 'Convert OTF to TTF',
    description => <<'_',

This program is a shortcut wrapper for <prog:fontforge>. This command:

    % otf2ttf foo.otf

is equivalent to:

    % fontforge -lang=ff -c 'Open($1); Generate($2); Close();' foo.otf foo.ttf

_
    args => {
        %argspec0_otf_file,
        %argspec1opt_ttf_file,
        %argspecopt_overwrite,
    },
    deps => {
        prog => 'fontforge',
    },
    links => [
        {url => 'prog:ttf2otf'},
    ],
};
sub otf2ttf {
    require IPC::System::Options;

    my %args = @_;

    my $otf_file = $args{otf_file};
    -f $otf_file or return [500, "File '$otf_file' does not exist or not a file"];

    my $ttf_file = $args{ttf_file};
    unless (defined $ttf_file) {
        ($ttf_file = $otf_file) =~ s/\.otf\z/.ttf/i;
    }
    $ttf_file eq $otf_file and return [412, "Please specify a different name for the output TTF file"];
    ((-f $ttf_file) && !$args{overwrite}) and return [412, "TTF file '$ttf_file' already exists, please specify another output name or use --overwrite"];

    IPC::System::Options::system(
        {log=>1, die=>1},
        "fontforge", "-lang=ff", "-c", 'Open($1); Generate($2); Close();', $otf_file, $ttf_file,
    );
    [200];
}

1;
# ABSTRACT: Command-line utilities related to fonts and font files

=head1 SYNOPSIS

This distribution provides tha following command-line utilities related to fonts
and font files:

#INSERT_EXECS_LIST


=head1 TODO

C<list-fonts> to list installed fonts on the system (in a cross-platform way).
Tab completion. Filtering OTF/TTF, etc.

C<< show-fonts <font names> [text] >> to show how fonts look. Allow specifying
wildcards. Allow specifying filename for source of text. Tab completion.

C<< install-font <font files> >> and C<< uninstall-font <font names> >> to
install and uninstall fonts (in a cross-platform way). Allow specifying
regex/wildcard in uninstall. Tab completion.

C<<search-font>>


=head1 SEE ALSO

=cut
