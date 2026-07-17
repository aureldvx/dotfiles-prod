" ==============================================================================
"  CONFIGURATION DE BASE (ADMINISTRATION VPS)
" ==============================================================================
set nocompatible              " Désactive la compatibilité vi (indispensable)
set encoding=utf-8            " Encodage universel
set backspace=indent,eol,start " Comportement moderne de la touche Retour arrière
set history=1000              " Historique des commandes étendu

" --- Recherche intelligente ---
set hlsearch                  " Surligne les correspondances de recherche
set incsearch                 " Recherche incrémentale (pendant la saisie)
set ignorecase                " Ignore la casse lors de la recherche...
set smartcase                 " ...sauf s'il y a une majuscule

" --- Performance & Fichiers temporaires ---
set nobackup                  " Pas de fichiers de sauvegarde inutiles
set noswapfile                " Pas de fichiers .swp qui polluent le VPS
set nowritebackup
set autoread                  " Recharge le fichier s'il a été modifié ailleurs

" --- Ergonomie & Indentation ---
set number                    " Affiche les numéros de ligne
set ruler                     " Affiche la position du curseur en bas à droite
set scrolloff=5               " Laisse 5 lignes visibles sous/sur le curseur
set showcmd                   " Affiche la commande en cours de frappe
set wildmenu                  " Menu d'autocomplétion visuel pour les commandes
set tabstop=4                 " Largeur d'une tabulation
set shiftwidth=4              " Largeur d'indentation pour '>' et '<'
set expandtab                 " Transforme les tabulations en espaces (standard VPS)

" ==============================================================================
"  THÈME VISUEL & TRUE COLORS (NATIVEMENT VIA GHOSTTY)
" ==============================================================================
syntax on                     " Active la coloration syntaxique
set termguicolors             " Active True Color

" Force la transparence pour TOUS les thèmes chargés
autocmd ColorScheme * highlight Normal guibg=NONE ctermbg=NONE
autocmd ColorScheme * highlight LineNr guibg=NONE ctermbg=NONE
autocmd ColorScheme * highlight SignColumn guibg=NONE ctermbg=NONE

" Application de la palette Catppuccin chargée depuis pack/
colorscheme catppuccin

" Nettoyage visuel de la barre de statut (plus élégante et épurée)
set laststatus=2
set statusline=%f\ %m\ %r%=%y\ [%p%%]\ %l:%c

" ==============================================================================
"  RACCOURCIS CLAVIERS UTILS (ADMINISTRATION)
" ==============================================================================
" Espace comme touche Leader
let mapleader=" "

" Sauvegarde rapide avec Espace + w
noremap <Leader>w :w<CR>
" Quitter rapidement avec Espace + q
noremap <Leader>q :q<CR>

" Désactive le surlignage de recherche avec Espace + l (Clear Search)
nnoremap <Leader>l :nohlsearch<CR>

" Reste en mode visuel après indentation d'un bloc avec > ou <
vnoremap < <gv
vnoremap > >gv
