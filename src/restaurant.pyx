from __future__ import print_function
cimport dishes
from dishes cimport spamdish

cdef void prepare(spamdish *d):
    d.oz_of_spam = 42
    d.filler = dishes.sausage

def serve():
    cdef spamdish d
    prepare(&d)
    print(f'{d.oz_of_spam} oz spam, filler no. {d.filler}')

    
cdef another_dish(spamdish * d, spam=0, filler=0):
    #cdef spamdish d;
    #d = (spamdish *) sd;
    if filler == 0:
        d.filler = dishes.sausage
    elif filler == 1:
        d.filler = dishes.eggs
    elif filler == 2:
        d.filler == dishes.lettuce
    else:
        raise ValueError('Unknown filler')
    d.oz_of_spam = spam
    
    print(f'{d.oz_of_spam} oz spam, filler no. {d.filler}')
    #return (void *) d
    
    
cdef class Dish:
    cdef spamdish dish 
    
    def __cinit__ (self, int spam, int filler):
            another_dish(&self.dish , spam , filler)
            
            
    def __str__(self):
        return f'{self.dish.oz_of_spam} oz spam, filler no. {self.dish.filler}'

    # define properties in the normal Python way
    
    @property
    def spam(self):
        return self.dish.oz_of_spam
    @property
    def filler(self):
        return self.dish.filler

    @spam.setter
    def spam(self,val):
        self.dish.oz_of_spam = val
    @filler.setter
    def filler(self,val):
        another_dish(&self.dish, self.spam, val)
        
        
        
    