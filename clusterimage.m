%step0:load image as input dataset
raw_im = Tiff('trees.tif','r');
im = raw_im.readRGBAImage();
im = im2double(im(1:200 ,1:200 , :));

%Set K
k = 5;
iter = 0;
%step1:randomly initialize means
prev_mu = rand(k,1,3);
new_mu = zeros(k,1,3);

while new_mu ~= prev_mu 
    if (iter > 0)
        prev_mu = new_mu;
    end
    z = zeros(k,1,3);
    sum = zeros(k,1,3);
    % step2: Find the closest mean for each point
    for i = 1:200
        for j = 1:200
            dist = zeros(1,k);
            for m = 1:k                                
                gap = im(i,j,:) - prev_mu(m,1,:);
                %preparation for norm
                gap = gap(:);
                dist(1,m) = norm(gap)^2;
            end 
            d_min = min(dist);
            % calculate sum(z) & sum(x*z)
            for n = 1:k
                gap = im(i,j,:) - prev_mu(n,1,:);
                gap = gap(:);
                dist = norm(gap)^2;
                if (dist == d_min)
                    z(n,1,:) = z(n,1,:) + 1;
                    sum(n,1,:) = sum(n,1,:) + im(i,j,:);
                end
            end
        end
        % step3: update means
        for q = 1:k
            new_mu(q,1,:) = sum(q,1,:)./z(q,1,:);
        end
    end  
    iter = iter + 1;
end

% Replace pixel values by the nearest centroid mean value
for i = 1:200
    for j = 1:200
        dist = zeros(1,k);
        for m = 1:k
            gap = im(i,j,:) - new_mu(m,1,:);
            gap = gap(:);
            dist(1,m) = norm(gap)^2;
        end
        d_min = min(dist);
        for n=1:k
            gap = im(i,j,:) - new_mu(n,1,:);
            gap = gap(:);
            dist = norm(gap)^2;
            % replace 
            if (dist == d_min)
                im(i,j,:) = new_mu(n,1,:);
            end
        end
    end
end

% Show K-means clustering result
imshow(im)
