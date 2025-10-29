# Why ?

Because…

Un petit document qui expliquent certains choix de développement faits.

## Ordre des arguments

Lorsqu'on écrit une fonction, il faut garantir que l'ordre est cohérent avec les autres fonctions du package. Je propose :

1) `path`
2) `version_number`
3) `gh_repo`
4) `branch`
5) `target`
6) `verbose`

## Documentation et `@inheritParams`

Pour faire des économies de documentation, on recycle les documentations des arguments.

Ainsi :

- `set_latest_deps_version()` documente `path` et `verbose`
- `change_remotes_field()` documente `target`
- `get_latest_version()` documente `gh_repo`
- `get_version_from_branch()` documente `branch`
- `get_different_future_version()` documente `version_number`
