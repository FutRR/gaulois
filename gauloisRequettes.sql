-- 1. Nom des lieux qui finissent par 'um'.
SELECT * FROM lieu WHERE nom_lieu LIKE "%um"

-- 2. Nombre de personnages par lieu (trié par nombre de personnages décroissant).
SELECT nom_lieu, COUNT(id_personnage) AS personnages FROM personnage
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
GROUP BY personnage.id_lieu
ORDER BY COUNT(id_personnage) DESC


-- 3. Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom
-- de personnage.
SELECT nom_personnage, nom_specialite, adresse_personnage, nom_lieu
FROM personnage
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
INNER JOIN specialite ON personnage.id_specialite = specialite.id_specialite
ORDER BY nom_lieu, nom_personnage

-- 4. Nom des spécialités avec nombre de personnages par spécialité (trié par nombre de
-- personnages décroissant).
SELECT specialite.nom_specialite, COUNT(id_personnage)
FROM personnage
INNER JOIN specialite ON personnage.id_specialite = specialite.id_specialite
GROUP BY personnage.id_specialite
ORDER BY COUNT(id_personnage) DESC

-- 5. Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne (dates affichées
-- au format jj/mm/aaaa).
SELECT nom_bataille, DATE_FORMAT(date_bataille, "%d/%m/%Y") AS date_bataille
FROM bataille
ORDER BY date_bataille DESC

-- 6. Nom des potions + coût de réalisation de la potion (trié par coût décroissant).
SELECT nom_potion, SUM(qte*cout_ingredient) AS coutPotion
FROM composer
INNER JOIN potion ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
GROUP BY composer.id_potion
ORDER BY SUM(qte*cout_ingredient) DESC

-- 7. Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'.
SELECT nom_ingredient, cout_ingredient, qte
FROM composer
INNER JOIN potion ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
WHERE composer.id_potion = 3


-- 8. Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village
-- gaulois'.
SELECT nom_personnage, SUM(qte) AS nbCasque
FROM personnage, bataille, prendre_casque
WHERE personnage.id_personnage = prendre_casque.id_personnage
AND bataille.id_bataille = prendre_casque.id_bataille
AND nom_bataille = 'Bataille du village gaulois'

GROUP BY personnage.id_personnage

HAVING nbCasque >= ALL(
    SELECT SUM(qte)
    FROM prendre_casque, bataille
    WHERE bataille.id_bataille = prendre_casque.id_bataille
    AND nom_bataille = 'Bataille du village gaulois'
    GROUP BY id_personnage
)

-- 9. Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur
-- au plus petit).
SELECT nom_personnage, dose_boire
FROM boire
INNER JOIN personnage ON boire.id_personnage = personnage.id_personnage
ORDER BY dose_boire DESC

-- 10. Nom de la bataille où le nombre de casques pris a été le plus important.
SELECT nom_bataille, SUM(qte) AS nbCasque
FROM bataille, prendre_casque
WHERE bataille.id_bataille = prendre_casque.id_bataille

GROUP BY bataille.id_bataille

HAVING nbCasque >= ALL(
    SELECT SUM(qte)
    FROM prendre_casque, bataille
    WHERE bataille.id_bataille = prendre_casque.id_bataille
    AND nom_bataille = 'Bataille du village gaulois'
    GROUP BY bataille.id_bataille
)

-- 11. Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par
-- nombre décroissant)
SELECT COUNT(id_casque) AS nbCasque, SUM(cout_casque) AS coutCasque, nom_type_casque
FROM casque
INNER JOIN type_casque ON casque.id_type_casque = type_casque.id_type_casque
GROUP BY casque.id_type_casque
ORDER BY SUM(cout_casque) DESC

-- 12. Nom des potions dont un des ingrédients est le poisson frais.
SELECT nom_potion
FROM potion
INNER JOIN composer ON potion.id_potion = composer.id_potion
INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
WHERE composer.id_ingredient = 24

-- 13. Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.
SELECT nom_lieu, COUNT(id_personnage) AS nbPersonnages
FROM personnage, lieu
WHERE lieu.id_lieu = personnage.id_lieu
AND nom_lieu <> 'Village gaulois'

GROUP BY lieu.id_lieu

HAVING nbPersonnages >= ALL(
    SELECT COUNT(id_personnage)
    FROM personnage, lieu
    WHERE lieu.id_lieu = personnage.id_lieu
    AND nom_lieu <> 'Village gaulois'
    GROUP BY lieu.id_lieu
)




-- 14. Nom des personnages qui n'ont jamais bu aucune potion.
SELECT nom_personnage
FROM personnage
WHERE id_personnage NOT IN (SELECT id_personnage FROM boire)

-- 15. Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'

SELECT nom_personnage
FROM personnage
WHERE id_personnage NOT IN (SELECT id_personnage FROM autoriser_boire WHERE id_potion = 1)

-- En écrivant toujours des requêtes SQL, modifiez la base de données comme suit :

-- A. Ajoutez le personnage suivant : Champdeblix, agriculteur résidant à la ferme Hantassion de
-- Rotomagus.
INSERT INTO personnage (nom_personnage, adresse_personnage, id_lieu, id_specialite)
VALUES ('Champdeblix', 'Ferme Hantassion', '6', '12')

-- B. Autorisez Bonemine à boire de la potion magique, elle est jalouse d'Iélosubmarine...
INSERT INTO autoriser_boire (id_potion, id_personnage)
VALUES ('1', '12')

-- C. Supprimez les casques grecs qui n'ont jamais été pris lors d'une bataille.
DELETE FROM casque 
WHERE id_type_casque = 2 AND id_casque NOT IN (SELECT id_casque FROM prendre_casque)

-- D. Modifiez l'adresse de Zérozérosix : il a été mis en prison à Condate.
UPDATE personnage
SET adresse_personnage = 'Prison', id_lieu = 9
WHERE id_personnage = 23

-- E. La potion 'Soupe' ne doit plus contenir de persil.
DELETE FROM composer
WHERE id_ingredient = 19 AND id_potion = 9

-- F. Obélix s'est trompé : ce sont 42 casques Weisenau, et non Ostrogoths, qu'il a pris lors de la
-- bataille 'Attaque de la banque postale'. Corrigez son erreur !
UPDATE prendre_casque
SET id_casque = 10, qte = 42
WHERE id_casque = 14 AND id_personnage = 5 AND id_bataille = 9