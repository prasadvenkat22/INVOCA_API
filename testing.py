#python3 -m venv myenv

def test(  x):
  print(x)

print(test(10))


def extendlist ( x , item=[]  ):  # this will cause a runt time error cant pass list as list #val causes error cant be reused
    item.append(x)
    return list


list1=extendlist(10)
print(list1)
list3 = extendlist('a')
#list2-extendlist(123,[])
def sumlist(items=[]):
    sum = 0
    for i in items:
        sum += i

    return sum

t=sumlist([2,4,8,1])
print(t)
def my_fun(my_list):
    my_list.append(1)

    return my_list


x = [1, 2, 3]
y = my_fun(x)

print(f"x: {x}, y: {y}")
# x, y are both [1, 2, 3, 1]

print(list1)
print(list3)

class Parent(object):
    x=1
class Child1(Parent):
    pass
class Child2(Parent):
    pass

print (Parent.x, Child1.x, Child2)
print (Parent.x, Child1.x, Child2.x)
print (Parent.x, Child1.x, Child2.x)

#myenv\scripts\activate.x

# args is used to pass a non-key worded, variable-length argument list
def myFun(*argv): 
    for arg in argv: 
        print (arg)
h=myFun(13, 14, 15, 15)
##kwargs keyworded, variable-length argument list like dictionaries
def myFunk(**kwargs): 
    for key, value in kwargs.items():
        print ("%s == %s" %(key, value))
 
kwargs = {"1" : "Geeks", "2" : "for", "3" : "Geeks"}
 
d=myFunk(**kwargs)
 
myFunk(coffee="Mocha", price=2.90, size="Large", when="after brakfast")
myFunk(coffee="Mocha", price=2.90, size="Large")
def myFunkList(l): 
    for s in l:
        print (s)
mylist = ["abc", 123, {1,2,3}]
myFunkList(mylist)
myFun(*mylist)
 
class Person:
  def __init__(self, name, age):
    self.name = name
    self.age = age=[]
 
p1 = Person("John", 36)
p2 = Person("Venkat", 63)
print(p1.name)
print(p1.age)
 
print(p2.name)
print(p2.age)
#variable keywords customer order
#The self parameter is a reference to the current instance of the class, and is used to access variables that belong to the class.
 
class Student(Person):
  def __init__(self, fname, lname, year):
    super().__init__(fname, lname)
    self.graduationyear = year
    #you are adding this as superclass varaible as well
 
x = Student("Eshwar", "Tang", 2022)
#By using the super() function, you do not have to use the name of the parent element, 
# it will automatically inherit the methods and properties from its parent.
#In Python we have lists that serve the purpose of arrays, 
# #but they are slow to process.
 
#NumPy aims to provide an array object that is up to 50x faster than traditional Python lists.
#array object in NumPy is called ndarray
 
from re import I, L
import numpy as np
 
#step you can use step funtion to reverse steing or even for loop to 
# reverse string
#use step syntax to do left and right sub arrasy and multiply products
def test(a):
  for index, number in enumerate(a):
    print(index, "->", number)



def solution(a):
    c=[]
    if( len(a) == 1):
          n=a[0]
          c.append([n])
          return c
    b=[]
    for i,n in enumerate(a):
      #enumerate is what you want to get index and value
      if i==0:
        v=a[i] + a[i + 1]
        print(v)
      elif i==len(a)-1:
        v=a[i] + a[i -1]
        print(v)
      else:
        v=a[i - 1] + a[i] + a[i + 1]
        print(v)
      b.append ( v)    
    
 
    print(b)
    return b
a = [4, 0, 1, -2, 3]
result1= (solution(a)) 
a = [9]
print(solution(a)) 
# for i in range(length):
#     print(list[i])
# Array a mutates into a new array b of the same length
# For each i from 0 to a.length - 1 inclusive, b[i] = a[i - 1] + a[i] + a[i + 1]
# If some element in the sum a[i - 1] + a[i] + a[i + 1] does not exist, it is considered to be 0
#solution(a) = [4, 5, -1, 2, 1].
# 2 d arrays
 
def solution1(a):
  b=[]
  d=dict()
  for n in a:
    y = [int(a) for a in str(n)]
    print(y) 
    for x in y:
      if int(x) in d:
        d[x] = d[x] + 1
      else:
        d[x] = 1
  
  for k,v in d.items():
    print(k, v)
  count = 0
 
  print(len([v for v in d.values() if int(v) >= 2]))
  print(([v for v in d.keys() if int(v) >= 1]))
 
  for k,v in d.items():
    if int(v) in d and int(v) >= 2 in d:
      print(k)
      b.append(k)
  
  return b
  print(b)
 
a=[25, 2, 3, 57, 38, 41] 
a=[2, 2, 3, 4, 4, 41]  
result=solution1(a)
print(result)
def solution4(s, t):
 if len(s) > len(t):
    n=len(s)
 else:
    n=len(t)
 c=1
 for i in range(0,n):
     
    for u in s:
        for v in t:
            if s[u] == t[v]:
                c += c
 return c
 s= "ab12c"
 t= "1zz456"
 result = solution4(s,t)
 
print(x)
 
from itertools import zip_longest
 
def solution2(a):
  lst= []
  longest_word = len(max(a, key=len)) # find longest word in a list
 
  emptystr = ""
  for i in a:     # combine list of words to a string
    emptystr += i +''
  strs=""
  for i in range(0,longest_word):
    for word in a:
      for w in word:
        if i < len(word):
          strs = strs + word[i]
          break
  return ("".join(strs))
 
a=[25, 2, 3, 57, 38, 41]    
result=solution1(a)
print(result)
arr = ["Daisy", "Rose", "Hyacinth", "Poppy"]
#, the output should be solution(arr) = "DRHPaoyoisapsecpyiynth".
result=solution2(arr)
 
def find_dupes_in_list(my_list):
 
  opt = [item for item in set(my_list) if my_list.count(item) > 1]
  # you are not over writing the my_list with set(my_list) yet so 
  # we compare in set mylist with mylist and see what is in there with
  #count of >1 that is cool
  print(opt)
 
  opt=[x for x in my_list if my_list.count(x) >= 2]
  #this will give the duplicated values
  print(opt)
  return opt
  
result=find_dupes_in_list( [3, 5, 2, 1, 4, 4, 1])
 
def solution3(a,m,k):
  a1= [a[i:j + 1] for i in range(len(a)) for j in range(i + 1, len(a))]
  #print(a1) # this prints all subarrys
  for sa in a1:
    if len(sa) == m:
      for e in sa:
        for i in range(len(sa)):#check if subarray adds to k!!!!wow
            for j in range(i+1, len(sa)):
              if sa[i] + sa[j] == k:
                print(sa)
                return True
 
# = [2, 4, 7, 5, 3, 5, 8, 5, 1, 7], m = 4, and k = 10, the output should be solution(a, m, k) = 5.
result= solution3([2, 4, 7, 5, 3, 5, 8, 5, 1, 7],4,10)
result1  = solution3( [15, 8, 8, 2, 6, 4, 1, 7], m = 2,  k = 8)
 
def solution7(a):
  a1= [a[i:j + 1] for i in range(len(a)) for j in range(i + 1, len(a))]
  #print(a1) # this prints all subarrys
  k=0
  for sa in a1:
    for e in sa:
      for i in range(len(sa)):#check if subarray adds to k!!!!wow
        k=sa[i] + sa[i+1] 
        for j in range(i+1, len(sa)):
            if sa[i] + sa[j] == k:
              print(sa)
              return True
 
def solution8(numbers):
  numbers.sort()
  for i in range(len(numbers)):
      for j in range(i+1, len(numbers)):
        if numbers[j] * numbers[j] == numbers[i]:
          print(numbers)
          return numbers[i]   
a= [25, 35, 872, 228, 53, 278, 872]
numbers= [-1, 18, 3, 1, 5]
results8=solution8(numbers)
#find anagrams that is cases wehre 872=278
 
# Let's consider all subarrays of length m = 4 and see which fit the description conditions:
 
# Subarray a[0..3] = [2, 4, 7, 5] doesn't contain any pair of integers with a sum of k = 10. 
# Note that although the pair (a[3], a[3]) has the sum 5 + 5 = 10, it doesn't fit the requirement s ≠ t.
# Subarray a[1..4] = [4, 7, 5, 3] contains the pair (a[2], a[4]), where a[2] + a[4] = 7 + 3 = 10.
# Subarray a[2..5] = [7, 5, 3, 5] contains two pairs (a[2], a[4]) and (a[3], a[5]), both with a sum of k = 10.
# Subarray a[3..6] = [5, 3, 5, 8] contains the pair (a[3], a[5]), where a[3] + a[5] = 5 + 5 = 10.
# Subarray a[4..7] = [3, 5, 8, 5] contains the pair (a[5], a[7]), where a[5] + a[7] = 5 + 5 = 10.
# Subarray a[5..8] = [5, 8, 5, 1] contains the pair (a[5], a[7]), where a[5] + a[7] = 5 + 5 = 10.
# Subarray a[6..9] = [8, 5, 1, 7] doesn't contain any pair with a sum of k = 10.
# So the answer is 5, because there are 5 contiguous subarrays that contain a pair with a sum of k = 10.
 
def solution5(s, t):
 if len(s) < len(t):
    n=len(s)
 else:
    n=len(t)
 c=1
 for i in range(0,n):
     
    for u in s:
        for v in t:
            if s[i] == t[i]:
                c += c
 return c
s= "ab12c"
t= "1zz456"
results= solution5(s,t)
arr = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
print(arr)
print(arr[0])
print(arr[4:])
print(arr[:4])
#array slicing
print(arr[-3:-1])
print(arr[1:5:2])
#In the case of 2D lists, each element is another list
def solution6(field, x, y):
  for i in range(len(field)):
    for j in range(len(field[x])):
      print(field[i][j])
    
x= 3
y= 3 
field = [ [False,True,True] , 
          [False,False,True],  
          [False,False,True]]
 
results6  =solution6(field, 1,1)
 
twodarr = np.array([[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]])
 
print(twodarr[1, 1:4])
print(twodarr[0:2, 1:4])
newarr = arr.reshape(4, 3)
print(newarr)
newarr1 = newarr.reshape(-1) #reshape back to one D
print(newarr1)
#In SQL we join tables based on a key, whereas in NumPy we join arrays by axes.
 
x = np.where(arr == 4)
 
twodarr = np.array([[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]])
 
print(twodarr[1, 1:4])
print(twodarr[0:2, 1:4])
newarr = arr.reshape(4, 3)
print(newarr)
newarr1 = newarr.reshape(-1) #reshape back to one D
print(newarr1)
#In SQL we join tables based on a key, whereas in NumPy we join arrays by axes.
 
x = np.where(arr == 4)
 
print(x)
 
def findduplicatedinarray(mylist): 
  newlist = [] # empty list to hold unique elements from the list
  duplist = [] # empty list to hold the duplicate elements from the 
  for i in mylist:
    if i not in newlist:
      newlist.append(i)
    else:
      duplist.append(i) # this method catches the first duplicate entries, and appends them to the list
  print("List of duplicates", duplist)
  print("Unique Item List", newlist) # prints the final list of unique items 
  #dup = {x for x in mylist if mylist.count(x) > 1}
  #print(dup)--to just print count of dupes using list expression
  #fastert wasy is use a set
  #myunique = set(mylist) # prints the final list without any duplicates
dup=[1,2,3,3,4,5]
d=findduplicatedinarray(dup)

