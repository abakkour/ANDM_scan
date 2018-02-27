function tf = isvalidhandle(h)
if isempty(h)
    tf = false;
elseif isscalar(h)
    tf = ishandle(h);
    if ~isnumeric(h) % ~verLessThan('matlab', '8.4')
        tf = tf && isvalid(h);
    end
else
    tf = ishandle(h);
    if ~isnumeric(h(tf)) % ~verLessThan('matlab', '8.4')
        tf(tf) = isvalid(h(tf));
    end
end