# README - Décodeur Soft LDPC

## Description

Ce projet implémente un décodeur soft pour les codes LDPC (Low-Density Parity-Check) en MATLAB. Le décodeur utilise un algorithme de **propagation de croyances (Belief Propagation)** pour corriger les erreurs dans les mots de code reçus, en exploitant une matrice de parité de faible densité. Le but est de ramener les mots de code corrompus à leur forme correcte en appliquant plusieurs itérations de mises à jour de messages entre les nœuds variables (v-nodes) et les nœuds de contrôle (c-nodes) de la matrice de parité.

## Fichiers

- `SOFT_DECODER_GROUPE.m`: Fonction MATLAB implémentant le décodeur soft LDPC.
- `LDPC_STUDENT_TEST_SCRIPT.m` (fichier externe de test, non inclus ici) : Script de test qui exécute et évalue le décodeur en comparant les résultats avec des solutions de référence.

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
