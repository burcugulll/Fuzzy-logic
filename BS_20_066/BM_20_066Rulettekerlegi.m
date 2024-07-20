function secilen_indeks = BM_20_066Rulettekerlegi(fitness_degerleri)
    % Gelen fitness değerleri üzerinden seçim yap
    uygunluk_toplami = sum(fitness_degerleri);
    
    % Her bireyin seçilme olasılığını hesapla
    olasiliklar = fitness_degerleri / uygunluk_toplami;
    
    % Rulet tekerleğini simüle et
    rulet = cumsum(olasiliklar);
    
    % Rastgele bir sayı üret
    rastgele_sayi = rand();
    
    % Hangi bireyin seçildiğini belirle
    secilen_indeks = find(rulet >= rastgele_sayi, 1, 'first');
end