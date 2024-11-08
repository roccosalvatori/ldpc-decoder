# Projet de Décodeur Soft LDPC

Ce projet implémente un décodeur soft pour les codes LDPC (Low-Density Parity-Check) en MATLAB. Le décodeur utilise un algorithme de **propagation de croyances (Belief Propagation)** pour corriger les erreurs dans les mots de code reçus, en exploitant une matrice de parité de faible densité. Le but est de ramener les mots de code corrompus à leur forme correcte en appliquant plusieurs itérations de mises à jour de messages entre les nœuds variables (v-nodes) et les nœuds de contrôle (c-nodes) de la matrice de parité.

## Contenu du projet

- **`SOFT_DECODER_GROUPE.m`** : Fonction principale implémentant le décodeur soft pour les codes LDPC.
- **`LDPC_SOFT_ONLY_TEST_SCRIPT.m`** : Script de test pour valider le décodeur soft à partir d'un jeu de données et comparer avec les résultats de référence.
- **Script d'analyse BER** : Script additionnel pour évaluer le décodeur en fonction du BER, du nombre d'itérations moyennes, et de la fréquence des arrêts anticipés, avec affichage graphique.

## Fonctionnalités Principales

### 1. `SOFT_DECODER_GROUPE.m`
Cette fonction prend en entrée un mot de code bruité et utilise une matrice de vérification de parité `H` pour corriger les erreurs bit à bit. Elle utilise une technique de message-passing entre les noeuds de variable et les noeuds de vérification pour propager les probabilités de chaque bit, ce qui permet de raffiner les estimations jusqu'à convergence.

#### Entrées
- **c** : Mot de code bruité (vector).
- **H** : Matrice de vérification de parité (matrice binaire).
- **p** : Vecteur de probabilités de bit-flip.
- **MAX_ITER** : Nombre maximal d'itérations pour le décodeur.

#### Sorties
- **c_cor** : Mot de code corrigé.
- **iter_count** : Nombre d'itérations effectuées avant la convergence.

#### Fonctionnement
La fonction suit deux étapes principales à chaque itération :
1. **Mise à jour des messages des noeuds de vérification vers les noeuds de variable** en calculant les probabilités conditionnelles de chaque bit.
2. **Mise à jour des messages des noeuds de variable vers les noeuds de vérification** en fonction des messages reçus des noeuds de vérification voisins.

Un arrêt anticipé est déclenché si les contraintes de parité sont satisfaites avant `MAX_ITER` itérations.

### 2. `LDPC_SOFT_ONLY_TEST_SCRIPT.m`
Ce script exécute le décodeur soft sur un ensemble de données et compare les résultats obtenus avec des mots de code de référence pour vérifier la précision de la correction d'erreurs.

#### Fonctionnalités
- **Chargement de jeu de données** : Chargement de `student_dataset.mat` pour accéder aux mots de code bruités et probabilités associées.
- **Comparaison avec référence** : Comparaison des mots de code décodés avec les mots de code de référence pour évaluer les performances.
- **Affichage des résultats** : Affichage des taux de réussite pour chaque cas testé.

#### Sorties
- Taux de réussite des correspondances entre le code de référence et le code décodé par le décodeur soft.

### 3. Script d’Analyse de la Performance (BER et plus)
Ce script réalise un test de performance en simulant la transmission de mots de code avec différentes probabilités de bruit et analyse les performances du décodeur en termes de :
- **Taux d'erreur binaire (BER)** : Fréquence de bits incorrectement décodés.
- **Nombre d'itérations moyen** : Mesure de la vitesse de convergence du décodeur.
- **Taux d'arrêt anticipé** : Fréquence à laquelle le décodeur atteint une solution avant la fin des itérations maximales.

#### Sorties graphiques
Les résultats sont affichés dans des graphes montrant l'évolution de :
- **BER en fonction de la probabilité de bruit**
- **Nombre moyen d'itérations en fonction de la probabilité de bruit**
- **Taux d'arrêt anticipé en fonction de la probabilité de bruit**
- **BER en fonction du nombre moyen d'itérations**

## Utilisation

1. **Exécuter le décodeur sur un ensemble de données** :
   - Lancez `LDPC_SOFT_ONLY_TEST_SCRIPT.m` pour tester le décodeur sur des données chargées et afficher les comparaisons avec les références.

2. **Tester la performance avec BER** :
   - Lancez le script d'analyse de BER pour évaluer les performances du décodeur sous différentes probabilités de bruit et obtenir des graphiques détaillés.

## Exemples

### Exemple d’Appel de la Fonction de Décodeur
```matlab
% Définir les paramètres
c_bruite = [1; 0; 1; 1; 0; 1; 0];  % Exemple de mot de code bruité
H = [
    1 1 0 1 1 0 0;
    1 0 1 1 0 1 0;
    1 0 0 0 1 1 1;
    0 1 1 0 0 1 1
];
p = [0.1; 0.1; 0.1; 0.1; 0.1; 0.1; 0.1];
MAX_ITER = 10;

% Appel du décodeur
[c_corrige, iterations] = SOFT_DECODER_GROUPE(c_bruite, H, p, MAX_ITER);
disp(c_corrige);
disp(iterations);
```

### Exécution du Test et Affichage Graphique
Exécutez le script d'analyse BER pour obtenir les performances du décodeur en utilisant différentes probabilités de bruit :
```matlab
% Exécuter le script pour obtenir les graphiques de performance
run('LDPC_SOFT_DECODER_TEST.m')
```

## Améliorations Futures
Ce projet est en cours de développement. Les améliorations futures pourraient inclure :
- Optimisation de l'algorithme pour des matrices `H` de grande taille.
- Intégration d’une estimation de BER plus rapide pour des ensembles de données larges.
- Analyse de complexité et ajustements pour améliorer la convergence.

## Auteurs et Remerciements

**Auteur** : Lélio CHETOT  
**Date** : 31 Octobre 2023 🎃  

---

Ce projet vise à fournir une base pour les étudiants et les chercheurs souhaitant explorer et optimiser les décodeurs LDPC soft.
```




