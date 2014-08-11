#!/usr/bin/env perl
#
# $Id: $
# $Revision: $
# $Author: $
# $Source:  $
#
# $Log: $
#
use strict;
use warnings;
use Test::More;
use DBICx::TestDatabase;
use Data::Printer;

use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/tlib";

BEGIN { use_ok('TestSchema') }

my $schema = DBICx::TestDatabase->new('TestSchema');
isa_ok($schema, 'DBIx::Class::Schema');

my $trees = $schema->resultset('MultiTree');
isa_ok($trees, 'DBIx::Class::ResultSet');

my $tree1 = $trees->create({ content => 'tree1 root', root_id => 10});
my $tree2 = $trees->create({ content => 'tree2 root', root_id => 20});

is_deeply(
    [map { $_->lft} $tree1],
    [map { $_->lft} $tree2],
    'Tree 1 is organised at lft correctly before deletion of all nodes.',
);

is_deeply(
    [map { $_->rgt} $tree1],
    [map { $_->rgt} $tree2],
    'Tree 1 is organised at rgt correctly before deletion of all nodes.',
);


# Add children to tree1
my $child1_0 = $tree1->create_rightmost_child({ content => 'child1'});
my $child1_1 = $child1_0->create_rightmost_child({ content => 'child1-1'});
my $child1_2 = $child1_0->create_rightmost_child({ content => 'child1-2'});
my $child1_3 = $child1_0->create_rightmost_child({ content => 'child1-3'});

foreach my $n ( $tree1, $child1_0, $child1_1, $child1_2, $child1_3 ) {
    $n->discard_changes;
}

my $nodes_1 = $schema->resultset('MultiTree')->search_rs( { root_id => 10 }, { order_by => 'lft' });

while ( my $n = $nodes_1->next ) { 

    printf STDERR "Node ID %i LFT %i RGT %i ROOT %i\n", $n->id, $n->lft, $n->rgt, $n->root_id;
}

# Delete remaining nodes except root
$child1_0->delete;


$tree1->discard_changes;
$tree2->discard_changes;

my $nodes_2 = $schema->resultset('MultiTree')->search_rs( { root_id => [10,20] }, { order_by => 'root_id,lft' });

while ( my $n = $nodes_2->next ) { 

    printf STDERR "Node ID %i LFT %i RGT %i ROOT %i\n", $n->id, $n->lft, $n->rgt, $n->root_id;
}



is_deeply(
    [map { $_->lft} $tree1],
    [map { $_->lft} $tree2],
    'Tree 1 is organised at lft correctly after deletion of all nodes.',
);

p $tree1;
p $tree2;

is_deeply(
    [map { $_->rgt} $tree1],
    [map { $_->rgt} $tree2],
    'Tree 1 is organised at rgt correctly after deletion of all nodes.',
);


done_testing();
exit;

