#!/usr/bin/env perl

use v5.10;
use warnings;
use strict;
use JSON;
use Data::Dumper;
use File::Slurp;
use Getopt::Long qw(GetOptions);  

die "No GITHUB_TOKEN env var\n" unless $ENV{GITHUB_TOKEN};
my $TOKEN = $ENV{GITHUB_TOKEN};

my $GITHUB_GRAPHQL_API_URL = "https://api.github.com/graphql";
my $HEADERS = "'Authorization: Bearer $TOKEN'";

sub usage {
  return "Usage: GITHUB_TOKEN=XXXXXXX $0 --from=DATE --to=DATE --repo-owner=STRING --repo-file=STRING\n";
}

sub curl {
  my ($url, $query) = @_;

  my $cmd = "curl -f -s -H $HEADERS -X POST --data '{ \"query\": $query }' $url";
  # print $cmd;

  return `$cmd`;
}

sub build_gql_query {
  my ($repo_owner, $repo_name, $repo_branch, $from, $to) = @_;

  my $gql_query = "{ repository(owner: \\\"$repo_owner\\\", name: \\\"$repo_name\\\") { refs(first: 1, refPrefix: \\\"refs/heads/\\\", query: \\\"$repo_branch\\\") { edges { node { target { ... on Commit { history(first: 0, since: \\\"$from\\\", until: \\\"$to\\\") { totalCount } } } } } } } }";
  my $query_wrapper = "\" $gql_query \"";

  return $query_wrapper;
}

sub get_commits_by_repo_name {
  my $response = curl($GITHUB_GRAPHQL_API_URL, build_gql_query(@_));
  die "Error in curl execution, maybe GITHUB_TOKEN is wrong?\n" unless $? == 0;

  my $ref = decode_json($response);
  return $ref->{"data"}->{"repository"}->{"refs"}->{"edges"}[0]->{"node"}->{"target"}->{"history"}->{"totalCount"};
};

my ($from, $to, $repo_owner, $repo_file);
GetOptions(
  'from=s' => \$from,
  'to=s' => \$to,
  'repo-owner=s' => \$repo_owner,
  'repo-file=s' => \$repo_file
);
die usage() unless $from and $to and $repo_owner and $repo_file;
die "\n".$repo_file." not exists\n".usage() unless -e $repo_file;
$from = $from."T00:00:00";
$to = $to."T00:00:00";

my $repos_json_raw = read_file($repo_file);
my $ref = decode_json($repos_json_raw);
print "repo_name, repo_branch, commit_count\n";
foreach ( @{$ref}) {
  my $repo_name = $_->{"name"};
  my $repo_branch = $_->{"master_branch"};

  my $commit_count = get_commits_by_repo_name($repo_owner, $repo_name, $repo_branch, $from, $to);
  print "$repo_name, $repo_branch, $commit_count\n";
  sleep(1);
}
