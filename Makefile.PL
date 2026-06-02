use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'API::hCaptcha',
    VERSION_FROM => 'lib/API/hCaptcha.pm',
    AUTHOR => 'Cesar Tessarin, <cesar@tessarin.com.br>',

    MIN_PERL_VERSION => 'v5.42',

    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '7.78',
    },
    PREREQ_PM => {
        'JSON' => '4.10',
        'REST::Client' => '281',
    },

    META_MERGE => {
        dynamic_config => 0,
        resources => {
            repository => 'https://github.com/tessarin/hCaptcha',
            bugtracker => 'https://github.com/tessarin/hCaptcha/issues',
        },
    },
    LICENSE => 'mit',

    clean => { FILES => 'cover_db' },

    EXE_FILES => [ glob 'bin/*' ],
);
