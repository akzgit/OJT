import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

# Parameters
g = 9.81  # gravity (m/s^2)
elasticity = 0.8  # elasticity coefficient (0 < e < 1)
time_interval = 0.025  # time interval for the animation (s)
initial_height = 10  # initial height (m)
squish_factor = 0.25  # factor by which the ball squishes

# Initial conditions
y = initial_height
v = 0  # initial velocity
t = 0  # initial time

# Lists to store positions
y_positions = [y]

# Update function for the animationimport numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

# Parameters
g = 9.81  # gravity (m/s^2)
elasticity = 0.8  # elasticity coefficient (0 < e < 1)
time_interval = 0.005  # time interval for the animation (s)
initial_height = 10  # initial height (m)
squish_factor = 0.5  # factor by which the ball squishes

# Initial conditions
y = initial_height
v = 0  # initial velocity
t = 0  # initial time

# Lists to store positions
y_positions = [y]

# Update function for the animation
def update(frame):
    global y, v, t
    t += time_interval
    v -= g * time_interval  # update velocity
    y += v * time_interval  # update position
    
    # Check for bounce
    if y <= 0:
        y = 0
        v = -v * elasticity
    
    y_positions.append(y)
    
    if y == 0:
        ball.set_markersize(20 * squish_factor)
    else:
        ball.set_markersize(20)
        
    ball.set_data([0], [y])
    return ball,

# Set up the figure and axis
fig, ax = plt.subplots()
ax.set_xlim(-1, 1)
ax.set_ylim(0, initial_height + 1)
ball, = ax.plot([], [], 'o', markersize=20)

# Create the animation
ani = animation.FuncAnimation(fig, update, frames=np.arange(0, 200, time_interval), blit=True, repeat=False)

# Show the animation
plt.show()

def update(frame):
    global y, v, t
    t += time_interval
    v -= g * time_interval  # update velocity
    y += v * time_interval  # update position
    
    # Check for bounce
    if y <= 0:
        y = 0
        v = -v * elasticity
    
    y_positions.append(y)
    
    if y == 0:
        ball.set_markersize(20 * squish_factor)
    else:
        ball.set_markersize(20)
        
    ball.set_data([0], [y])
    return ball,

# Set up the figure and axis
fig, ax = plt.subplots()
ax.set_xlim(-1, 1)
ax.set_ylim(0, initial_height + 1)
ball, = ax.plot([], [], 'o', markersize=20)

# Create the animation
ani = animation.FuncAnimation(fig, update, frames=np.arange(0, 200, time_interval), blit=True, repeat=False)

# Show the animation
plt.show()
