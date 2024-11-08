# README - Décodeur Soft LDPC

## Description

Ce projet implémente un décodeur soft pour les codes LDPC (Low-Density Parity-Check) en MATLAB. Le décodeur utilise un algorithme de **propagation de croyances (Belief Propagation)** pour corriger les erreurs dans les mots de code reçus, en exploitant une matrice de parité de faible densité. Le but est de ramener les mots de code corrompus à leur forme correcte en appliquant plusieurs itérations de mises à jour de messages entre les nœuds variables (v-nodes) et les nœuds de contrôle (c-nodes) de la matrice de parité.

## Fichiers

- `SOFT_DECODER_GROUPE.m`: Fonction MATLAB implémentant le décodeur soft LDPC.
- `LDPC_STUDENT_TEST_SCRIPT.m` (fichier externe de test) : Script de test qui exécute et évalue le décodeur en comparant les résultats avec des solutions de référence.

## Fonctionnalité principale

La fonction **SOFT_DECODER_GROUPE** corrige un mot de code reçu en plusieurs étapes :
1. **Initialisation** : Initialise les messages de croyance pour chaque bit reçu en fonction de sa probabilité d’être correct ou erroné.
2. **Propagation des messages** : Envoie des messages entre les nœuds variables (v-nodes) et les nœuds de contrôle (c-nodes) selon les probabilités de chaque bit. 
3. **Mise à jour des estimations de bits** : À chaque itération, la fonction met à jour les estimations de chaque bit pour corriger les erreurs potentielles.
4. **Vérification des contraintes de parité** : Vérifie si les contraintes de parité sont satisfaites et s'arrête si elles le sont avant la fin du nombre maximal d'itérations.

## Utilisation

### Prérequis

Ce code est conçu pour être utilisé avec MATLAB.

### Fonction : SOFT_DECODER_GROUPE

La fonction prend les paramètres suivants :

```matlab
function c_cor = SOFT_DECODER_GROUPE(c, H, p, MAX_ITER)

```

- **c** : Vecteur colonne binaire reçu (de dimension `[N, 1]`), représentant le mot de code potentiellement corrompu.
- **H** : Matrice de parité logique (`[M, N]`), qui définit les contraintes de parité du code LDPC.
- **p** : Vecteur colonne de probabilités (`[N, 1]`), où chaque élément `p(i)` est la probabilité que le bit `c(i)` soit égal à 1.
- **MAX_ITER** : Nombre maximal d'itérations du décodeur.

### Exemple d’appel

```matlab
H = logical([0 1 0 1 1 0 0 1; 
             1 1 1 0 0 1 0 0;
             0 0 1 0 0 1 1 1;
             1 0 0 1 1 0 1 0]);
c = [1; 0; 1; 0; 1; 1; 0; 0];
p = [0.9; 0.1; 0.8; 0.3; 0.6; 0.7; 0.2; 0.5];
MAX_ITER = 100;

c_cor = SOFT_DECODER_GROUPE(c, H, p, MAX_ITER);
disp(c_cor);
```

### Explication de l’algorithme

1. **Initialisation des messages de croyance** : 
   Chaque bit reçoit une probabilité initiale `p(i)` d’être égal à 1 ou 0, définie dans le vecteur `q(i, :, 1)` pour `0` et `q(i, :, 2)` pour `1`.

2. **Propagation des messages entre les nœuds** :
   - **Étape 1** : Pour chaque nœud de contrôle (c-node), calcule les messages de croyance vers chaque nœud variable connecté (v-node), en fonction des probabilités des autres nœuds connectés.
   - **Étape 2** : Pour chaque nœud variable, met à jour ses messages vers les nœuds de contrôle, en utilisant les messages de retour des c-nodes pour les recalculer.

3. **Mise à jour des estimations des bits** :
   - Pour chaque bit, la probabilité qu'il soit `0` ou `1` est recalculée à partir des messages reçus de ses nœuds de contrôle.
   - Une estimation est faite pour chaque bit en choisissant la probabilité la plus forte entre `0` et `1`.

4. **Condition d'arrêt** :
   - La boucle se termine dès que toutes les contraintes de parité sont satisfaites ou lorsque le nombre maximal d'itérations est atteint.

### Résultats

La fonction retourne un vecteur `c_cor`, qui est le mot de code corrigé après le décodage. Ce mot de code est ensuite comparé au mot de code d'origine ou de référence pour évaluer la précision de correction.

## Points à vérifier et ajustements

1. **Matrice de parité** : Vérifiez que la matrice `H` soit définie correctement et respecte les règles de construction LDPC.
2. **Probabilités initiales (`p`)** : Assurez-vous que le vecteur `p` reflète la probabilité correcte de chaque bit de la séquence d'entrée.
3. **Nombre d'itérations** : Adaptez `MAX_ITER` en fonction des besoins en précision et de la performance de calcul.



