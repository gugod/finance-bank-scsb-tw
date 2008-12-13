
use ExtUtils::MakeMaker;

WriteMakefile(
    AUTHOR              => 'Kang-min Liu (gugod@gugod.org)',
    ABSTRACT            => 'Retrive bank balance from SCSB online bank',
    NAME                => 'Finance::Bank::SCSB::TW',
    VERSION_FROM        => 'lib/Finance/Bank/SCSB/TW.pm',
    DISTNAME            => 'Finance-Bank-SCSB-TW',
    # EXE_FILES		=> [ 'scsb-check-balance' ],
    PREREQ_PM           => {
        'WWW::Mechanize'   => '0',
        'HTML::Selector::XPath' => 0,
        'HTML::TreeBuilder::XPath' => 0,
    },
    dist                => {
        COMPRESS        => 'gzip -9',
        SUFFIX          => '.gz',
    },
);

