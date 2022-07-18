#!/usr/bin/env python
# coding: utf-8

# In[589]:


import numpy as np
import pandas as pd
import os


# In[ ]:


ZADANIE 1


# In[ ]:


podatek_dochod = 0.17
skl_emeryt, skl_rentow, skl_chorob = 0.0976, 0.0150, 0.0245
ubezp_zdrow_staw1, ubezp_zdrow_staw2 = 0.09, 0.0775
koszt_uzyskania = 250.00
kwota_wolna = 43.76
placa_brutto = 3200
emeryt = skl_emeryt * placa_brutto
rentow = skl_rentow * placa_brutto
chorob = skl_chorob * placa_brutto
spoleczn = emeryt + rentow + chorob
przychod = placa_brutto - spoleczn
zdrow = ubezp_zdrow_staw1 * przychod
podst_opod = przychod - koszt_uzyskania
podatek = podatek_dochod ** podst_opod - kwota_wolna
podatek -= ubezp_zdrow_staw2 * przychod
placa_netto = placa_brutto - spoleczn - zdrow - podatek 

print(' Płaca brutto: %f \n * Ub. społeczne: %f \n *** Ub. emeryt.: %f \n *** Ub. rentow.: %f \n *** Ub. chorob.: %f \n * Ub. zdrowotne: %f \n * Podatek doch.: %f \n Płaca netto: %f ' % (
placa_brutto, spoleczn, emeryt, rentow, chorob, zdrow, podatek, placa_netto
))


# In[ ]:


ZADANIE 2


# In[364]:


pts1 = np.array([3, 1, 3, 2, 1, 3, 2, 3, 2, 1, 3, 2, 1, 3, 3])

pres2 = np.array([
True, True, True, True, False, True, True, True, True,
True, False, False, True, False, True
], dtype = int)

home2 = np.array(['perf', 'perf', 'perf', 'good', 'good', 'good', 'perf', 'none', 'good', 'good', 'good', 'none', 'good', 'perf', 'good'], dtype = str)

pts2 = pts1 + pres2

change_home2 = np.where(home2 == "perf",2 ,1 and home2 == 'good')

print(f"zadanie 2.1. {pts2}")
print(f"zadanie 2.2. {change_home2}")


# In[375]:


pts1 = [3, 1, 3, 2, 1, 3, 2, 3, 2, 1, 3, 2, 1, 3, 3]

pres2 = [
True, True, True, True, False, True, True, True, True,
True, False, False, True, False, True
]
home2 = [
'perf', 'perf', 'perf', 'good', 'good', 'good', 'perf',
'none', 'good', 'good', 'good', 'none', 'good', 'perf',
'good']

pts2 = pts1
for i in range(len(pts2)):
    pts2[i] += 1 if pres2[i] else 0

if home2[i] == 'perf':
    pts2[i] += 2
elif home2[i] == 'good':
    pts2[i] += 1
else:
    pts2[i] += 0

print(pts2)
print(pts1)
print("zadanie 2.3. pts1 jest takie jak pts2 ponieważ zadziałało przypisanie przez referencje (w tym miejscu: pts2 = pts1), mają to samo miejsce w pamięci i jeśli zmieniamy jedno to zadziała to też na drugie.")


# In[ ]:


ZADANIE 3


# In[384]:


path_fs = r'C:\Users\olaja\Desktop\anaconda\frankenstein.txt'
fs = open(path_fs, 'r', encoding="utf-8")
fs = fs.read()
sfs = split(fs)

def check_freq(x):
    return {c: x.count(c) for c in set(x) if c != ' ' and c != '\ufeff'}

check_freq(sfs)


# In[ ]:


ZADANIE 4


# In[ ]:


hosp = (15444, 16144, 16427, 17223, 18160, 18654, 19114)

def transform2(ts, func):
    return [func(v0, v1) for v0, v1 in zip(hosp[:-1], hosp[1:])]

print(transform2(hosp, lambda x0, x1: x1 - x0))

zmiana_procentowa = transform2(hosp, lambda x0, x1: round((x1 - x0) * 100 / x0, 2))
print(zmiana_procentowa)


# In[ ]:


ZADANIE 5


# In[ ]:


class Sample:
    def __init__ (self, val):
        self.val = val
    def get_vals(self):
        return self.val
    def get_val(self, i):
        return self.val[i - 1]
    
    def set_val(self, i, new_val):
        self.val.remove(self.val[i-1])
        self.val.insert(i-1, new_val)
        return self.val
        
    def add_val(self, last_val):
        self.val.append(last_val)
        return self.val
            
    
    
    
s = Sample([1, 2, 3])
print(s.get_vals())
print(s.get_val(1))

print(s.set_val(1, 222))
print(s.get_vals())

print(s.add_val(4657))
print(s.get_vals())


# In[ ]:


ZADANIE 6


# In[ ]:


class Sample(object):
    def __init__ (self, val):
        self.val = val
    def get_vals(self):
        return self.val
    def get_val(self, i):
        return self.val[i - 1]
    
    def set_val(self, i, new_val):
        self.val.remove(self.val[i-1])
        self.val.insert(i-1, new_val)
        return self.val
        
    def add_val(self, last_val):
        self.val.append(last_val)
        return self.val
    
    
class ExtSample(Sample):
    def __init__ (self, val):
        self.val = val
        super().__init__(val) 
    def sum(self):
        return sum(self.val)
    def mul(self):
        return np.prod(self.val)
    def avg(self):
        return np.mean(self.val)
    
es = ExtSample([1, 2, 3, 4])
print(es.get_vals())
print(es.add_val(5))
print(es.get_vals())
print(es.sum())
print(es.mul())
print(es.avg())    


# In[ ]:


ZADANIE 7


# In[722]:


class Vector:
    def __init__(self, a, b, c, d):
        self.a = a
        self.b = b
        self.c = c
        self.d = d

    def __add__(self, other):
        if isinstance(other, Vector):
            return Vector(self.a + other.a, self.b + other.b, self.c + other.c, self.d + other.d)
        else:
            return Vector(self.a + float(other), self.b + float(other), self.c + float(other), self.d + float(other))
    
    def __mul__(self, other):
        if isinstance(other, Vector):
            return self.a * other.a, self.b * other.b, self.c * other.c, self.d * other.d
        else:
            return Vector(self.a * float(other), self.b * float(other), self.c * float(other), self.d * float(other)) 
        
v1 = Vector(1, 2, 1, 5)
v2 = Vector(2, 3, 1, 4)

v3 = v1 + v2
v4 = v1 *v2

print(v3)
print(v4)


# In[ ]:


ZADANIE 8


# In[690]:


import pyreadr
import os
os.chdir(r'C:\Users\olaja\Desktop\anaconda')
bank = (pyreadr.read_r('./bank_register.rds'))[None]

bank[['client_id','agreement_id']] = bank.id.str.split('_',expand=True)
bank.drop('id', axis=1, inplace=True)
bank['date'] = pd.to_datetime(bank.date)



bank[['sex','age', 'child']] = bank.demographic.str.split(',',expand=True)
bank.drop('demographic', axis=1, inplace=True)

bank = bank.assign(dep = lambda x: x['products'].map(lambda dx: True if dx == 'DEP' else False)).assign(cre = lambda x: x['products'].map(lambda dx: True if dx == 'CRE' else False)).assign(mor = lambda x: x['products'].map(lambda dx: True if dx == 'MOR' else False))

bank = bank.reindex(columns=['client_id','agreement_id', 'date', 'income', 'sex', 'age', 'child', 'dep', 'cre', 'mor'])

print(bank)


# In[ ]:


ZADANIE 9 (po wielu próbach nie udało mi się sensownie wczytać tabeli więc wrzucam moje propozycje rozwiązań podpunktów 'na sucho')


# In[596]:


diamonds = pd.read_csv("ugly_diamonds.csv", delimiter='%', header = 0, )

diamonds.price.groupby(diamonds.cut and diamonds.color).agg(['mean','median','sdt'])

diamonds.assign(new = [diamonds['cut'] == 'Premium'], inplace = True)

d2 = diamonds.copy(deep=True)
d2.assign(V = d2['x'] + d2['y'] + d2['z'], inplace = True)

d2.clarity.value_counts(normalize=True)

print(diamonds)

