# Github Commits Retriever

## Requirements
- perl v5.10
- curl
- Unix-like OS
- Github Token

## Usage
```
 GITHUB_TOKEN=XXXXXXXXXXXXX ./github.pl --from=2023-01-01 --to=2023-10-11 --repo-owner=Owner --repo-file=./repos-clean.json
```

The `--repo-file` is a JSON file that contains the name of the repositories and the main branch for each of them.
The structure should be like this:
```
[
  {
    "name": "repo1",
    "master_branch": "main"
  },
  {
    "name": "repo2",
    "master_branch": "master"
  },
  {
    "name": "repo3",
    "master_branch": "master"
  },
  ...
]
```
