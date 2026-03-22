// Script d'initialisation de la base de données Firestore
// À exécuter une seule fois pour initialiser les espèces

// Species de base pour peupler la base de données
const speciesList = [
  // Oiseaux
  {
    id: 'robin',
    commonName: 'Rouge-gorge',
    scientificName: 'Erithacus rubecula',
    type: 'bird',
    description: 'Petit oiseau chanteur au plumage brun-gris et à la poitrine rouge caractéristique.',
    tags: ['commun', 'oiseau', 'automne', 'hiver'],
    isVerified: true,
  },
  {
    id: 'blackbird',
    commonName: 'Merle noir',
    scientificName: 'Turdus merula',
    type: 'bird',
    description: 'Grand oiseau chanteur au plumage noir brillant avec un bec jaune.',
    tags: ['commun', 'oiseau', 'noir'],
    isVerified: true,
  },
  {
    id: 'sparrow',
    commonName: 'Moineau domestique',
    scientificName: 'Passer domesticus',
    type: 'bird',
    description: 'Petit oiseau très commun, souvent vu en bandes dans les zones urbaines.',
    tags: ['très commun', 'urbain', 'oiseau'],
    isVerified: true,
  },
  
  // Plantes
  {
    id: 'daisy',
    commonName: 'Pâquerette',
    scientificName: 'Bellis perennis',
    type: 'plant',
    description: 'Petite fleur blanche et jaune très commune dans les pelouses.',
    tags: ['fleur', 'blanche', 'commun', 'printemps'],
    isVerified: true,
  },
  {
    id: 'rose',
    commonName: 'Rosier',
    scientificName: 'Rosa',
    type: 'plant',
    description: 'Arbuste ornemental portant des fleurs colorées souvent parfumées.',
    tags: ['fleur', 'coloré', 'ornemental'],
    isVerified: true,
  },
  {
    id: 'nettle',
    commonName: 'Ortie',
    scientificName: 'Urtica dioica',
    type: 'plant',
    description: 'Plante herbacée recouverte de poils urticants, commune dans les terrains vagues.',
    tags: ['forêt', 'mauvaise herbe', 'allergies'],
    isVerified: true,
  },
  
  // Insectes
  {
    id: 'ladybug',
    commonName: 'Coccinelle',
    scientificName: 'Coccinellidae',
    type: 'insect',
    description: 'Petit coléoptère rouge à pois noirs, très utile pour le jardin.',
    tags: ['utile', 'coloré', 'printemps', 'été'],
    isVerified: true,
  },
  {
    id: 'butterfly',
    commonName: 'Papillon',
    scientificName: 'Lepidoptera',
    type: 'insect',
    description: 'Insecte aux ailes couvertes d\'écailles colorées.',
    tags: ['beauté', 'coloré', 'printemps', 'été'],
    isVerified: true,
  },
  {
    id: 'bee',
    commonName: 'Abeille',
    scientificName: 'Apis mellifera',
    type: 'insect',
    description: 'Insecte hyménoptère important pour la pollinisation.',
    tags: ['pollinisateur', 'utile', 'fleurs'],
    isVerified: true,
  },
  
  // Mammifères
  {
    id: 'squirrel',
    commonName: 'Écureuil',
    scientificName: 'Sciurus vulgaris',
    type: 'mammal',
    description: 'Petit mammifère rongeur aux oreilles pointues et à la queue touffue.',
    tags: ['forêt', 'arboricole', 'commun'],
    isVerified: true,
  },
  {
    id: 'badger',
    commonName: 'Blaireau',
    scientificName: 'Meles meles',
    type: 'mammal',
    description: 'Mammifère carnivore nocturne avec un pelage rayé noir et blanc.',
    tags: ['nocturne', 'forêt', 'difficilement observable'],
    isVerified: true,
  },
  {
    id: 'fox',
    commonName: 'Renard roux',
    scientificName: 'Vulpes vulpes',
    type: 'mammal',
    description: 'Petit canidé au pelage roux avec une queue blanche.',
    tags: ['carnivore', 'campagne', 'urbain'],
    isVerified: true,
  },
  
  // Reptiles
  {
    id: 'grass_snake',
    commonName: 'Couleuvre à collier',
    scientificName: 'Natrix natrix',
    type: 'reptile',
    description: 'Serpent inoffensif avec une bande jaune au cou.',
    tags: ['serpent', 'eau', 'harmless'],
    isVerified: true,
  },
  {
    id: 'common_lizard',
    commonName: 'Lézard des murailles',
    scientificName: 'Podarcis muralis',
    type: 'reptile',
    description: 'Petit lézard commun sur les rocailles et les murs.',
    tags: ['lézard', 'urbain', 'commun'],
    isVerified: true,
  },
  
  // Amphibiens
  {
    id: 'frog',
    commonName: 'Grenouille',
    scientificName: 'Rana temporaria',
    type: 'amphibian',
    description: 'Amphibien commun aux zones humides et berges.',
    tags: ['eau', 'coassement', 'printemps'],
    isVerified: true,
  },
  {
    id: 'toad',
    commonName: 'Crapaud',
    scientificName: 'Bufo bufo',
    type: 'amphibian',
    description: 'Amphibien robuste au pelage verruqueux.',
    tags: ['eau', 'utile', 'insectivore'],
    isVerified: true,
  },
];

// Instructions pour créer une fonction Cloud à exécuter
// 1. Créer une Cloud Function
// 2. Adapter le code ci-dessous
// 3. Exécuter depuis Firebase Console

async function initializeSpecies() {
  const db = admin.firestore();
  const batch = db.batch();
  
  for (const species of speciesList) {
    const docRef = db.collection('species').doc(species.id);
    batch.set(docRef, {
      ...species,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  
  await batch.commit();
  console.log(`${speciesList.length} espèces créées avec succès`);
}

// Ou directement dans Firestore CLI
// firestore:initialize --species
