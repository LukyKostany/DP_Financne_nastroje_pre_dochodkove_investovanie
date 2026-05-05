function [Finalny_nahradovy_pomer, AFS, w_SAP] = GLIDeS(Doba_sporenia_mesiace, Typ, Parametre, Vynosy_SAP_500, Hodnota_SeLFIES, Cieleny_realny_dochodkovy_prijem, Prispevky, Pocet_simulacii) % Funkcia na historickú simuláciu stratégie GLIDeS
% Vykoná historickú simulácia dôchodkovej sporivej stratégie GLIDeS
% Vypočíta finálny náhradový pomer a vráti vývoj AFS a podielu investovaných prostiedkov do akciového indexu SAP 500 pre dané nastavenie dôchodkovej investičnej stratégie GLIDeS

% Doba sporenia mesiace - koľko mesiacov si bude investor sporiť na dôchodok
% Typ - aký typ GLIDeS simulujeme
% Parametre - parametre danej stratégie GLIDeS
% Výnosy SAP 500 - mesačné logaritmické výnosy akciového indexu SAP 500
% Hodnota SeLFIES - Hodnoty SeLFIES s jednotlivými maturitami v každom mesiaci sporenia
% Cielený reálny dôchodkový príjem - sporiteľov stanovený garantovaný reálny mesačný dôchodkový príjem
% Príspevky - koľko peňažných jednotiek prispel sporiteľ do dôchodkovej investičnej stratégie daný mesiac sporenia
% Počet simulácii - koľko má byť vykonaných simulácií (1 - historická simulácia, 1000 - Monte-Carlo simulácia)

% Finálny náhradový pomer - výsledný finálny náhradový pomer sporiteľa dosiahnutý daným nastavením dôchodkovej investičnej stratégie GLIDeS

% Historická simulácia:
% Inicializácia vektorov:
AFS = zeros(Pocet_simulacii, Doba_sporenia_mesiace); % Inicializácia vektora aktuálneho stavu financovania cieľového reálneho dôchodkového príjmu
TFS = zeros(Doba_sporenia_mesiace); % Inicializácia vektora cileného stavu financovania cieľového reálneho dôchodkového príjmu
w_SAP = zeros(Pocet_simulacii, Doba_sporenia_mesiace); % Inicializácia vektora alokácie sporiteľových prostiedkov do akciového indexu SAP 500
w_SeLFIES = zeros(Pocet_simulacii, Doba_sporenia_mesiace); % Inicializácia vektora alokácie sporiteľových prostiedkov do nákupu dôchodkových dlhopisov SeLFIES
Hodnota_investicie_SAP_500 = zeros(Pocet_simulacii, Doba_sporenia_mesiace); % Inicializácia vektora hodnoty sporiteľových prostiedkov investovaných do akciového indexu SAP 500
Realny_prijem_zo_SAP_500 = zeros(Pocet_simulacii, Doba_sporenia_mesiace); % Inicializácia vektora reálneho príjmu dostupného z prostiedkov investovaných do akciového indexu SAP 500
Hodnota_drzanych_SeLFIES = zeros(Pocet_simulacii, Doba_sporenia_mesiace); % Inicializácia vektora hodnoty držaných dôchodkových dlhopisov SeLFIES
Pocet_kusov_SeLFIES = zeros(Pocet_simulacii, Doba_sporenia_mesiace); % Inicializácia vektora počtu držaných dôchodkových dlhopisov SeLFIES - reálneho príjmu z nich
Celkova_hodnota_prostriedkov = zeros(Pocet_simulacii, Doba_sporenia_mesiace); % Inicializácia vektora celkovej hodnoty investorových prostriedkov
Finalny_nahradovy_pomer = zeros(Pocet_simulacii, 1); % Inicializácia vektora výsledného náhradového pomeru sporiteľa


% Nastavenie parametrov GLIDeS:
if Typ == "Linear" % Ak ide o lineárne GLIDeS
   k = Parametre; % Nastavenie parametra k
elseif Typ == "Continous" % Ak ide o spojité GLIDeS
       l = Parametre(1); % Nastavenie parametra l
       z = Parametre(2); % Nastavenie parametra z
else % Ak ide o AFS-TFS GLIDeS
     b = Parametre; % Nastavenie parametra b
end

Posun = 528 - Doba_sporenia_mesiace; % Posun hodnôt pri odlišných obdobiach dôchodkového sporenia

% Hodnoty premenných v prvom mesiaci sporenia:
AFS(:, 1) = 0; % Aktuálny stav financovania cieľového reálneho dôchodkového príjmu v prvom mesiaci sporenia
TFS(1) = 1/480; % Cielený stav financovania cieľového reálneho dôchodkového príjmu v prvom mesiaci sporenia
if Typ == "AFS_TFS" % Ak ide o AFS-TFS GLIDeS
   w_SAP(:, 1) = 0.5; % Alokácia sporiteľových prostiedkov do akciového indexu SAP 500 v prvom mesiaci sporenia
else % Ak ide o lineárne alebo spojité GLIDeS
    w_SAP(:, 1) = 1; % Alokácia sporiteľových prostiedkov do akciového indexu SAP 500 v prvom mesiaci sporenia
end    
w_SeLFIES(:, 1) = 1 - w_SAP(:, 1); % Alokácia sporiteľových prostiedkov do nákupu dôchodkových dlhopisov SeLFIES v prvom mesiaci sporenia
Celkova_hodnota_prostriedkov(:, 1) = Prispevky(1); % Celková hodnota investorových prostriedkov v prvom mesiaci sporenia

for Simulacia = 1:Pocet_simulacii % Pre každú simuláciu
    for Mesiac_sporenia = 2:Doba_sporenia_mesiace % Pre každý mesiac sporenia
        Hodnota_investicie_SAP_500(Simulacia, Mesiac_sporenia) = w_SAP(Simulacia, Mesiac_sporenia - 1) * Celkova_hodnota_prostriedkov(Simulacia, Mesiac_sporenia - 1) * exp(Vynosy_SAP_500(Simulacia, Posun + Mesiac_sporenia - 1)); % Hodnota sporiteľových prostiedkov investovaných do akciového indexu SAP 500
        Realny_prijem_zo_SAP_500(Simulacia, Mesiac_sporenia) = Hodnota_investicie_SAP_500(Simulacia, Mesiac_sporenia) / Hodnota_SeLFIES(Posun + Mesiac_sporenia, (Doba_sporenia_mesiace + 1) - (Mesiac_sporenia)); % Reálny príjem dostupný z prostiedkov investovaných do akciového indexu SAP 500
    
        Pocet_kusov_SeLFIES(Simulacia, Mesiac_sporenia) = (w_SeLFIES(Simulacia, Mesiac_sporenia - 1) * Celkova_hodnota_prostriedkov(Simulacia, Mesiac_sporenia - 1)) / Hodnota_SeLFIES(Posun + Mesiac_sporenia - 1, (Doba_sporenia_mesiace + 1) - (Mesiac_sporenia - 1)); % Počet držaných dôchodkových dlhopisov SeLFIES - reálny príjem z nich
        Hodnota_drzanych_SeLFIES(Simulacia, Mesiac_sporenia) = Pocet_kusov_SeLFIES(Simulacia, Mesiac_sporenia) * Hodnota_SeLFIES(Posun + Mesiac_sporenia, (Doba_sporenia_mesiace + 1) - Mesiac_sporenia); % Hodnota držaných dôchodkových dlhopisov SeLFIES
    
        Celkova_hodnota_prostriedkov(Simulacia, Mesiac_sporenia) = Hodnota_investicie_SAP_500(Simulacia, Mesiac_sporenia) + Hodnota_drzanych_SeLFIES(Simulacia, Mesiac_sporenia) + Prispevky(Mesiac_sporenia); % Celková hodnota sporiteľových prostriedkov
    
        AFS(Simulacia, Mesiac_sporenia) = (Pocet_kusov_SeLFIES(Simulacia, Mesiac_sporenia) + Realny_prijem_zo_SAP_500(Simulacia, Mesiac_sporenia)) / Cieleny_realny_dochodkovy_prijem(Mesiac_sporenia); % Aktuálny stav financovania cieľového reálneho dôchodkového príjmu
        TFS(Mesiac_sporenia) = Mesiac_sporenia / Doba_sporenia_mesiace; % Cielený stav financovania cieľového reálneho dôchodkového príjmu
    
        if Typ == "Linear" % Ak ide o lineárne GLIDeS
           if AFS(Simulacia, Mesiac_sporenia) < 1 % Ak je aktuálny stav financovania cieľového reálneho dôchodkového príjmu menší ako 1
              w_SAP(Simulacia, Mesiac_sporenia) = max(1 - k * AFS(Simulacia, Mesiac_sporenia), 0); % Alokácia sporiteľových prostiedkov do akciového indexu SAP 500
           else % Ak je aktuálny stav financovania cieľového reálneho dôchodkového príjmu väčší alebo rovný 1
                w_SAP(Simulacia, Mesiac_sporenia) = 0; % Alokácia sporiteľových prostiedkov do akciového indexu SAP 500
           end
        elseif Typ == "Continous" % Ak ide o spojité GLIDeS 
               w_SAP(Simulacia, Mesiac_sporenia) = 1 - (1 / (1 + exp(-l * (AFS(Simulacia, Mesiac_sporenia) - z)))); % Alokácia sporiteľových prostiedkov do akciového indexu SAP 500
        else % Ak ide o AFS-TFS GLIDeS 
             w_SAP(Simulacia, Mesiac_sporenia) = 1 - (1 / (1 + exp(-b * (AFS(Simulacia, Mesiac_sporenia) - TFS(Mesiac_sporenia))))); % Alokácia sporiteľových prostiedkov do akciového indexu SAP 500
        end
    
        w_SeLFIES(Simulacia, Mesiac_sporenia) = 1 - w_SAP(Simulacia, Mesiac_sporenia); % Alokácia sporiteľových prostiedkov do nákupu dôchodkových dlhopisov SeLFIES v prvom mesiaci sporenia
    end
    
    Finalny_nahradovy_pomer(Simulacia) = AFS(Simulacia, end); % Výsledný náhradový pomer sporiteľa
end

end % Koniec funckie