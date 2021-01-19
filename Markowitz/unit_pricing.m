function [ C ] = unit_pricing( p,fu,fd,rf,delta_t )
%unit pricing.
C = (p*fu+(1-p)*fd)*exp(-rf*delta_t);

end