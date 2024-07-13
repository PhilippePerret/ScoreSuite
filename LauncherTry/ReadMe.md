Ce module est juste là pour travailler sur l’utilisation de Bundler pour appeler les différentes applications entre elles, de façon fluide.

Le problème qui m’a conduit a l’utiliser est le suivant : pas assez de réponses de différentes applications lorsque l’une lançait l’autre. Je pouvais les voir se bloquer sans apporter aucun message d’erreur ou produire aucun effet.

Ce module (`LauncherTry`) est donc principalement là pour développer la librairie générale **`lib/launcher`** qui doit être appelé par toutes les applications de la suite Score (et toutes les applications qui veulent travailler avec la suite Score.

## Principe immuable

Toutes les applications doivent être appelées par `bundle exec ruby` au départ, pour pouvoir fonctioner. Il faut donc modifier tous les liens symboliques qui fonctionnent avec les `score-image` et autres `score-builder`.
