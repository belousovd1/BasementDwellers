import random
random.seed(124332)
def quickselect(L, left=0, right=None):
    # Initialize right
    if right is None: right = len(L)

    # Partition into left and right sublists
    pivot = right - 1
    i, j = left, pivot-1

    while i<j:
        while L[i] < L[pivot]: i += 1
        while L[j] >= L[pivot] and i<j: j -= 1
        if L[i] > L[j]: L[i], L[j] = L[j], L[i]

    if L[i] >= L[pivot]:
        L[i], L[pivot] = L[pivot], L[i]
        pivot = i

    # Base case: we've found the median
    if pivot == len(L) // 2: return L[pivot]
    
    # Recursively call on sublist which contains median
    elif pivot > len(L) //2: return quickselect(L, left, pivot)
    elif pivot < len(L) //2: return quickselect(L, pivot+1, right)

    
n = 10
L = [random.randint(0,10) for i in range(n)]
L.append(-1)
print(L)
print(quickselect(L))