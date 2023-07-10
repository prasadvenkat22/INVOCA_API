my_list = [3, 5, 2, 1, 4, 4, 1]
opt = [item for item in set(my_list) if my_list.count(item) > 1]
# you are not over writing the my_list with set(my_list) yet so 
# we compare in set mylist with mylist and see what is in there with
#count of >1 that is cool
print(opt)


opt=[x for x in my_list if my_list.count(x) >= 2]
#this will give the duplicated values
print(opt)


sample_list = ["a", "ab", "a", "abc", "ab", "ab"]

def countOccurrence(a):
  k = {}
  for j in a:
    if j in k:
      k[j] +=1
    else:
      k[j] =1
  return k

print(countOccurrence(s))

def listofdupes(s):
    dup= set(x for x in s if s.count(s)>1 )

print(listofdupes(sample_list) )
    
def maxConsecutiveOccurrences(letter, string):
    count = 0
    maxCount = 0
    for ch in string:
        if ch == letter:
            count += 1
        else:
            count = 0
        if count > maxCount:
            maxCount = count
    return maxCount
maxConsecutiveOccurrences("F", "ABFFFBFFFFFBF")

import re
len(max(re.findall("F+", "ABFFFBFFFFFBF"), key=lambda x: len(x), default=[]))
