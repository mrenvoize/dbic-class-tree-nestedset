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
use Test::Exception;
use DBICx::TestDatabase;
use Data::Dumper;
use Data::Printer colored => 1;

use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/tlib";

BEGIN { use_ok('TestSchema') }

my $schema = DBICx::TestDatabase->new('TestSchema');
isa_ok($schema, 'DBIx::Class::Schema');

my $trees = $schema->resultset('MultiTree');
isa_ok($trees, 'DBIx::Class::ResultSet');

# Create the tree
my $tree1 = $trees->create({ content => '1 tree root', root_id => 1});

my $child1_1 = $tree1->add_to_children({ content => '1 child 1' });
my $gchild1_1 = $child1_1->add_to_children({ content => '1 g-child 1' });
my $child1_2 = $tree1->add_to_children({ content => '1 child 2' });
my $gchild2_1 = $child1_2->add_to_children({ content => '2 g-child 1' });

# Check that the test tree is constructed correctly
$tree1->discard_changes;

is_deeply(
    [map { $_->id} $tree1->nodes],
    [map { $_->id} $tree1, $child1_1, $gchild1_1, $child1_2, $gchild2_1],
    'Test Tree is organised correctly.',
);

# take cutting
$tree1->discard_changes;
$gchild1_1->discard_changes;
$gchild1_1->take_cutting;
$gchild1_1->discard_changes;
$tree1->discard_changes;

# attach cutting
$tree1->attach_rightmost_child($gchild1_1);
$tree1->discard_changes;

# child1_1 should now be a leaf
$child1_1->discard_changes;
ok( $child1_1->is_leaf, 'Child 1_1 is now leaf' );

# Check the test tree now looks as it should
is_deeply(
    [map { $_->id} $tree1->nodes],
    [map { $_->id} $tree1, $child1_1, $child1_2, $gchild2_1, $gchild1_1],
    'Updated Test Tree is organised correctly.',
);

done_testing();
exit;

