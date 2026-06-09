# Further work

## Mathematical considerations for moving an edge in a polygon

## Introduction

We define a polygon $\mathcal{P}$ as an ordered list of points $\{p_i, i \in \llbracket 0, \dots, n-1 \rrbracket\}$, on which edges $e
For the rest of the notations below, all indices are modulo $n$, meaning that $p_n$ is $p_0$.
We define edges as $e_i = (p_i, p_{i+1})$.
We assume that connecting all edges in that order gives a close, counter-clockwise and valid polygon.
Each pair of consecutive points $(p_i, p_{i+1})$ defines a directed line $l_i$.
Its direction $d_i$ is from $p_i$ to $p_{i+1}$.
This also means that $p_i$ is defined by the intersection of $l_{i-1}$ and $l_i$.
The normal of each line $l_i$ is called $n_i$ and we assume that it points "outwards" meaning that the angle from $n_i$ to $d_i$ in $\pi/2$ in trigonometrical direction.

We want to move each line $l_i$ by the distance $h_i$ in a specific direction $m$, and we want to know how much this increases or decreases the length of the edge $e_i$.
Since the three lines that define an edge can move independently but a tuple $(h_{i-1}, h_{i}, h_{i+1})$ gives the same edge (but translated) as $(h_{i-1} - h_{i}, 0, h_{i+1} - h_{i})$, we actually care about the differences $\Delta h_i =  h_i - h_{i-1}$ and $\Delta h_{i+1} = h_{i+1} - h_i$.
Therefore, we want to find a function $s(\Delta h_i, \Delta h_{i+1})$ which defines the length (size) of the edge $e_i$ depending on the shifts.

### Moving edges

Let's call $\alpha_{i}$ the angle from $n_i$ to $n_{i+1}$, and $\beta_{i}$ the angle from $m$ to $n_i$.
Let's call $d^{+}_{i}$ the impact of $\Delta h_{i+1}$ on $l_i$ and $d^{-}_{i}$ the impact of $\Delta h_{i}$ on $l_i$.
Therefore, we have $$s(\Delta h_i, \Delta h_{i+1}) = s(0, 0) + d^{+}_{i} + d^{-}_{i}$$

For computing these two values, we can assume that $h_{i+1} = 0$ and $h_{i-1} = 0$ respectively and therefore the deltas are only held by $h_{i}$.
Therefore, the shift in the direction of $n_i$ for $d^{+}_{i}$ is equal to $$h^{+}_{i} = \cos(\beta_i) \Delta h_{i+1}$$ and same for $$h^{-}_{i}= \cos(\beta_i) \Delta h_{i}$$
These values are signed, because the edge can grow or shrink.
More precisely, $d^{+}_{i}$ is defined as the distance between the initial position of $p_{i+1}$ and the projection of the shifted $p_{i+1}$ on the initial line before it was shifted.
We have different situations:

- If $0 < \alpha_{i-1} < \frac{\pi}{2}$, $\tan(\pi - \alpha_{i-1}) = -\frac{h^{-}_{i}}{d^{-}_{i}}$ so $d^{-}_{i} = -\frac{h^{-}_{i}}{\tan(\pi - \alpha_{i-1})} = \frac{h^{-}_{i}}{\tan(\alpha_{i-1})}$.
    It is negative because it shrinks if $h^{-}_{i} > 0$.
- Many other cases...

### Validity of polygons

For a given set of $\{h_{i} \;\forall i \in \llbracket 0, \dots, n-1 \rrbracket\}$ the polygon is valid if and only if $$\forall i \in \llbracket 0, \dots, n-1 \rrbracket, s(\Delta h_i, \Delta h_{i+1}) \geq 0$$

This will give us a system of $n$ equations of the form $$\lambda_i h_{i-1} + \mu_i h_{i} + \nu_i h_{i+1} \geq \omega_i$$ where we have $n$ variables which are the $h_i$ values.

### Solutions of interest

This system of equations will have an infinite amount of solutions.
We know this because setting all the $h_i$ to the same constant is equivalent to shifting the whole polygon and is therefore a solution.
This also means that we can set $h_{0} = H$ and we know that there will be a solution to the subsequent system of equations even if we have only $n-1$ variables left

However, these will still likely be an infinite amount of solutions, so we need to define which are the solutions we care about.
In general, our goal for the polygons is to first minimize the number of lines that need to be moved, and then minimize the shift that is applied to each line.
Moreover, we want that the impact of moving $l_0$ on $l_i$ decreases with the number of lines between $l_0$ and $l_i$.
