%% VK_KERNEL_MIDDLE Find a point which represents the "middle" of the kernel.
%   This is done by 'averaging' the points.
function C = vk_kernel_middle(V)
  C = sum(V,1)/size(V,1);
end
