liftdata=read.csv("C:/Users/lgh2811/Desktop/projects/lift_new.csv")
head(liftdata$obs)
attach(liftdata)
plot(cum~obs,data=liftdata,lables="Lift Curve of Discriminant Analysis")
slope=sum(y)/max(obs)
abline(a=0,b=slope)



banktrain=read.csv("C:/Users/lgh2811/Desktop/projects/banktrain.csv")   
attach(banktrain)

boxplot(balance~y,data=banktrain, 
        xlab="Response", ylab="balance")
boxplot(duration~y,data=banktrain,  
        xlab="Response", ylab="duration")
boxplot(previous~y,data=banktrain, main="Boxplot of Previous vs response", 
        xlab="Response", ylab="previous")
banktrainout=banktrain[which(previous>20 AND ),]
summary(banktrain$duration)

