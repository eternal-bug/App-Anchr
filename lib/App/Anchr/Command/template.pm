package App::Anchr::Command::template;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => "create executing bash files";

sub opt_spec {
    return (
        [ "basename=s", "the basename of this genome, default is the working directory", ],
        [ "genome=i",   "your best guess of the haploid genome size", ],
        [ "is_euk",     "eukaryotes or not", ],
        [ "tmp=s",      "user defined tempdir", ],
        [ "se",         "single end mode for Illumina", ],
        [ "trim2=s",      "steps for trimming Illumina reads",         { default => "--uniq" }, ],
        [ "sample2=i",    "total sampling coverage of Illumina reads", ],
        [ "coverage2=s",  "down sampling coverage of Illumina reads",  { default => "40 80" }, ],
        [ "qual2=s",      "quality threshold",                         { default => "25 30" }, ],
        [ "len2=s",       "filter reads less or equal to this length", { default => "60" }, ],
        [ "separate",     "separate each Qual-Len groups", ],
        [ "coverage3=s",  "down sampling coverage of PacBio reads", ],
        [ "parallel|p=i", "number of threads",                         { default => 16 }, ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr template [options] <working directory>";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= "\tFastq files can be gzipped\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( @{$args} != 1 ) {
        my $message = "This command need one directory.\n\tIt found";
        $message .= sprintf " [%s]", $_ for @{$args};
        $message .= ".\n";
        $self->usage_error($message);
    }
    for ( @{$args} ) {
        if ( !Path::Tiny::path($_)->is_dir ) {
            $self->usage_error("The input directory [$_] doesn't exist.");
        }
    }

    $args->[0] = Path::Tiny::path( $args->[0] )->absolute;

    if ( !$opt->{basename} ) {
        $opt->{basename} = Path::Tiny::path( $args->[0] )->basename();
    }

    $opt->{parallel2} = int( $opt->{parallel} / 2 );
    $opt->{parallel2} = 2 if $opt->{parallel2} < 2;

}

sub execute {
    my ( $self, $opt, $args ) = @_;

    # fastqc
    $self->gen_fastqc( $opt, $args );

    # kmergenie
    $self->gen_kmergenie( $opt, $args );

    # trim2
    $self->gen_trim( $opt, $args );

    # trimlong
    $self->gen_trimlong( $opt, $args );

    # statReads
    $self->gen_statReads( $opt, $args );

    # quorum
    $self->gen_quorum( $opt, $args );

    # statQuorum
    $self->gen_statQuorum( $opt, $args );

    # down_sampling
    $self->gen_down_sampling( $opt, $args );

    # kunitigs
    $self->gen_kunitigs( $opt, $args );

    # anchors
    $self->gen_anchors( $opt, $args );

    # statAnchors
    $self->gen_statAnchors( $opt, $args );

}

sub gen_fastqc {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "2_fastqc.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
cd [% args.0 %]

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t [% opt.parallel %] \
    ../R1.fq.gz [% IF not opt.se %]../R2.fq.gz[% END %] \
    -o .

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_kmergenie {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "2_kmergenie.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
cd [% args.0 %]

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

parallel --no-run-if-empty --linebuffer -k -j 2 "
    kmergenie -l 21 -k 121 -s 10 -t [% opt.parallel2 %] --one-pass ../{}.fq.gz -o {}
    " ::: R1  [% IF not opt.se %]R2[% END %]

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_trim {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "2_trim.sh";
    print "Create $sh_name\n";

    $tt->process(
        '2_trim.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_trimlong {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    if ( $opt->{coverage3} ) {
        $sh_name = "3_trimlong.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
cd [% args.0 %]

for X in [% opt.coverage3 %]; do
    printf "==> Coverage: %s\n" ${X}

    faops split-about -m 1 -l 0 \
        3_pacbio/pacbio.fasta \
        $(( [% opt.genome %] * ${X} )) \
        3_pacbio

    mv 3_pacbio/000.fa "3_pacbio/pacbio.X${X}.raw.fasta"
done

for X in  [% opt.coverage3 %]; do
    printf "==> Coverage: %s\n" ${X}

    anchr trimlong --parallel [% opt.parallel2 %] -v \
        "3_pacbio/pacbio.X${X}.raw.fasta" \
        -o "3_pacbio/pacbio.X${X}.trim.fasta"
done

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

}

sub gen_statReads {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statReads.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statReads.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_quorum {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    if ( !$opt->{separate} ) {
        $sh_name = "2_quorum.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Qual-Len: Q{1}L{2} <=='

    if [ ! -e R1.sickle.fq.gz ]; then
        echo >&2 '    R1.sickle.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    anchr quorum \
        R1.sickle.fq.gz [% IF not opt.se %]R2.sickle.fq.gz[% END %] \
        \$(
            if [[ {1} -ge '30' ]]; then
                if [ -e Rs.sickle.fq.gz ]; then
                    echo Rs.sickle.fq.gz;
                fi
            fi
        ) \
        -p [% opt.parallel %] \
        -o quorum.sh
    bash quorum.sh

    echo >&2
    " ::: [% opt.qual2 %] ::: [% opt.len2 %]

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }
    else {
        for my $qual ( grep {defined} split /\s+/, $opt->{qual2} ) {
            for my $len ( grep {defined} split /\s+/, $opt->{len2} ) {
                $sh_name = "2_quorum_Q${qual}L${len}.sh";
                print "Create $sh_name\n";
                $template = <<'EOF';
cd [% args.0 %]

cd 2_illumina/Q[% qual %]L[% len %]
echo >&2 '==> Qual-Len: Q[% qual %]L[% len %] <=='

if [ ! -e R1.sickle.fq.gz ]; then
    echo >&2 '    R1.sickle.fq.gz not exists'
    exit;
fi

if [ -e pe.cor.fa ]; then
    echo >&2 '    pe.cor.fa exists'
    exit;
fi

anchr quorum \
    R1.sickle.fq.gz [% IF not opt.se %]R2.sickle.fq.gz[% END %] \
    \$(
        if [[ [% qual %] -ge '30' ]]; then
            if [ -e Rs.sickle.fq.gz ]; then
                echo Rs.sickle.fq.gz;
            fi
        fi
    ) \
    -p [% opt.parallel %] \
    -o quorum.sh
bash quorum.sh

EOF
                $tt->process(
                    \$template,
                    {   args => $args,
                        opt  => $opt,
                        qual => $qual,
                        len  => $len,
                    },
                    Path::Tiny::path( $args->[0], $sh_name )->stringify
                ) or die Template->error;
            }
        }
    }

}

sub gen_statQuorum {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statQuorum.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statQuorum.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_down_sampling {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "4_down_sampling.sh";
    print "Create $sh_name\n";

    $tt->process(
        '4_down_sampling.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_kunitigs {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    if ( !$opt->{separate} ) {
        $sh_name = "5_kunitigs.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 4_Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'
    if [ -e 5_Q{1}L{2}X{3}P{4}_kunitigs/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 5_kunitigs_Q{1}L{2}X{3}P{4}
    cd 5_kunitigs_Q{1}L{2}X{3}P{4}

    anchr kunitigs \
        ../4_Q{1}L{2}X{3}P{4}/pe.cor.fa \
        ../4_Q{1}L{2}X{3}P{4}/environment.json \
        -p [% opt.parallel %] \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: [% opt.qual2 %] ::: [% opt.len2 %] ::: [% opt.coverage2 %] ::: $(printf "%03d " {0..50})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }
    else {
        for my $qual ( grep {defined} split /\s+/, $opt->{qual2} ) {
            for my $len ( grep {defined} split /\s+/, $opt->{len2} ) {
                for my $cov ( grep {defined} split /\s+/, $opt->{coverage2} ) {
                    $sh_name = "5_kunitigs_Q${qual}L${len}X${cov}.sh";
                    print "Create $sh_name\n";
                    $template = <<'EOF';
cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 4_Q[% qual %]L[% len %]X[% cov %]P{}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group Q[% qual %]L[% len %]X[% cov %]P{}'
    if [ -e 5_Q[% qual %]L[% len %]X[% cov %]P{}_kunitigs/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 5_kunitigs_Q[% qual %]L[% len %]X[% cov %]P{}
    cd 5_kunitigs_Q[% qual %]L[% len %]X[% cov %]P{}

    anchr kunitigs \
        ../4_Q[% qual %]L[% len %]X[% cov %]P{}/pe.cor.fa \
        ../4_Q[% qual %]L[% len %]X[% cov %]P{}/environment.json \
        -p [% opt.parallel %] \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh
    " ::: $(printf "%03d " {0..50})

EOF
                    $tt->process(
                        \$template,
                        {   args => $args,
                            opt  => $opt,
                            qual => $qual,
                            len  => $len,
                            cov  => $cov,
                        },
                        Path::Tiny::path( $args->[0], $sh_name )->stringify
                    ) or die Template->error;
                }
            }
        }
    }

}

sub gen_anchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    if ( !$opt->{separate} ) {
        $sh_name = "5_anchors.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 4_Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'
    if [ -e 5_Q{1}L{2}X{3}P{4}_kunitigs/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    rm -fr 5_kunitigs_Q{1}L{2}X{3}P{4}/anchor
    mkdir -p 5_kunitigs_Q{1}L{2}X{3}P{4}/anchor
    cd 5_kunitigs_Q{1}L{2}X{3}P{4}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: [% opt.qual2 %] ::: [% opt.len2 %] ::: [% opt.coverage2 %] ::: $(printf "%03d " {0..50})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }
    else {
        for my $qual ( grep {defined} split /\s+/, $opt->{qual2} ) {
            for my $len ( grep {defined} split /\s+/, $opt->{len2} ) {
                for my $cov ( grep {defined} split /\s+/, $opt->{coverage2} ) {
                    $sh_name = "5_anchors_Q${qual}L${len}X${cov}.sh";
                    print "Create $sh_name\n";
                    $template = <<'EOF';
cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 4_Q[% qual %]L[% len %]X[% cov %]P{}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group Q[% qual %]L[% len %]X[% cov %]P{}'
    if [ -e 5_Q[% qual %]L[% len %]X[% cov %]P{}_kunitigs/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    rm -fr 5_kunitigs_Q[% qual %]L[% len %]X[% cov %]P{}/anchor
    mkdir -p 5_kunitigs_Q[% qual %]L[% len %]X[% cov %]P{}/anchor
    cd 5_kunitigs_Q[% qual %]L[% len %]X[% cov %]P{}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh
    " ::: $(printf "%03d " {0..50})

EOF
                    $tt->process(
                        \$template,
                        {   args => $args,
                            opt  => $opt,
                            qual => $qual,
                            len  => $len,
                            cov  => $cov,
                        },
                        Path::Tiny::path( $args->[0], $sh_name )->stringify
                    ) or die Template->error;
                }
            }
        }
    }

}

sub gen_statAnchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statAnchors.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statAnchors.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

1;
