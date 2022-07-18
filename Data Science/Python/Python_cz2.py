#!/usr/bin/env python
# coding: utf-8

# In[107]:


import numpy as np
import pandas as pd
import pyreadr
import os


# In[ ]:


ZADANIE 1


# In[106]:


os.chdir(r'C:\Users\olaja\Desktop\anaconda')

cr = pyreadr.read_r(r".\crypto.rds")[None]
cr = cr[cr['Currency'] == 'bitcoin']
cr.drop(['Currency', 'Open', 'High', 'Volume', 'Low', 'Market.Cap'], axis=1, inplace=True)
pd.to_datetime(cr.Date)

cr.Date = pd.to_datetime(cr.Date, format='%b %d, %Y')
print('zamienic serie na cos co mozna zmienic na date')


cr = cr.assign(Rate = (cr.Close - (cr.Close-1))/(cr.Close-1))

cr.sort_values(by='Rate')

print(cr)
type(cr.Date)


# In[ ]:


ZADANIE 2


# In[105]:


albums = pd.read_csv("albums.csv")
albums.sort_values(by='num_of_sales')


print(albums)
type(albums)


# In[ ]:


ZADANIE 3.1


# In[240]:


os.chdir(r'C:\Users\olaja\Desktop\anaconda')
dfs = pyreadr.read_r(r".\suicides.rds")[None]

dfs.sort_values('suicides.100k.pop', inplace=True)
dfs1 = dfs[(dfs['year']>1985) & (dfs['year']<2016)]

print(f'Najmniej samobójstw na 100k: {dfs1.country.head(5)}')
print(f'Najwięcej samobójstw na 100k: {dfs1.country.tail(5)}')


# In[ ]:


ZADANIE 3.2


# In[249]:


dfs2 = dfs['suicides.100k.pop'].groupby(dfs.year).agg(['sum'])
print(dfs2)


# In[ ]:


ZADANIE 3.3


# In[261]:


dfs_sa = dfs.set_index(['sex', 'age'])
dfs3 = dfs_sa['suicides.100k.pop']
print(dfs3)


# In[ ]:


ZADANIE 4


# In[198]:


os.chdir(r'C:\Users\olaja\Desktop\anaconda')

free = pyreadr.read_r(r".\free_apps.rds")[None]
paid = pyreadr.read_r(r".\paid_apps.rds")[None]
norat = pyreadr.read_r(r".\norat_apps.rds")[None]


fpn= pd.concat([free, paid, norat], axis=0, ignore_index=True)
print(fpn)

fpn.to_csv('all_apps.csv', index=False)


# In[ ]:


print(free)
print(paid)
print(norat)

fp = free.merge(paid, on='App', how='outer').merge(norat,on='App', how='outer')


# In[ ]:


ZADANIE 5


# In[186]:


os.chdir(r'C:\Users\olaja\Desktop\anaconda')

movies = pyreadr.read_r(r".\movies.rds")[None]
ratings = pyreadr.read_r(r".\ratings.rds")[None]
tags = pyreadr.read_r(r".\tags.rds")[None]

mean_ratings = ratings.rating.groupby(ratings.movieId).agg(['mean'])
movies = pd.merge(movies, mean_ratings, on='movieId', how='outer')
print(movies)

last_tag = tags.timestamp.groupby(ratings.movieId).agg(['max'])
last_tag['max'] = pd.to_datetime(last_tag['max'], unit='s')
movies = pd.merge(movies, last_tag, on='movieId', how='outer')
print(movies)

join_tags = tags.tag.groupby(tags.movieId).apply(','.join).reset_index()
movies = pd.merge(movies, join_tags, on='movieId', how='outer')
print(movies)

