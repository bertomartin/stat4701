import numpy as np
from numpy import genfromtxt
import pylab as pl
from sklearn import linear_model, datasets
from sklearn import cross_validation, preprocessing
from sklearn.metrics import confusion_matrix
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier, ExtraTreesClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.svm import SVC, LinearSVC, SVR, NuSVC
import datetime 
import time
import calendar
from pandas import DataFrame
from pandas.stats import moments
import sys
from scipy import stats
import libs.TSCreator as TSCreator
from libs.ScoreLib import ThresholdAccuracyFunc as ThresholdScoreFunc
import libs.Kalman as Kalman
#import statsmodels.tsa.filters as stats_filters
from random import randint

"""
x = [13, 71, 120, 88, 82, 100, 10, 65, 101, 45, 26]
print moments.ewma(np.array(x), span=3)
sys.exit(0)

def scale(OldList, NewMin, NewMax):
    NewRange = float(NewMax - NewMin)
    OldMin = min(x)
    OldMax = max(x)
    OldRange = float(OldMax - OldMin)
    ScaleFactor = NewRange / OldRange
    print '\nEquasion:  NewValue = ((OldValue - ' + str(OldMin) + ') x '
+ str(ScaleFactor) + ') + ' + str(NewMin) + '\n'
    NewList = []
    for OldValue in OldList:
        NewValue = ((OldValue - OldMin) * ScaleFactor) + NewMin
        NewList.append(NewValue)
    return NewList

x = [13, 71, 120, 88, 82, 100, 10, 65, 101, 45, 26]
foo = scale(x, 0, 1.0)

##x = [.12789, .982779, .19798198, .266796, .656527, .257877091]
##foo = scale(x, 0, 127)

##x = [0, 50, 100]
##foo = scale(x, 32, 212)

##x = [32, 122, 212]
##foo = scale(x, 0, 100)

print 'New List = ' + str(foo)
"""

o_ind = 0
h_ind = 1
l_ind = 2
c_ind = 3
v_ind = 4


def clv(h,l,c):
	return (((c - l) - (h - c)) / (h - l)) if (h - l) != 0 else 0


def rsi(rs):
	return 100-(100/(1+rs))


def scale(vect,desired_min,desired_max):
	result = []
	vect_min = min(vect)
	vect_max = max(vect)
	print vect_min, vect_max
	for i in range(0,len(vect)):
		#print float(((desired_max-desired_min)*(vect[i] - min(vect))) / (max(vect) - min(vect))) + desired_min
		a = desired_max-desired_min
		b = vect[i] - vect_min
		c = vect_max - vect_min
		try:
			result.append(float(a*b) / float(c) + desired_min) 
		except:
			print vect[0:10], i
			raise
	return result

def pivot(arr_2D):
	result = np.reshape(arr_2D,(len(arr_2D[0]),len(arr_2D)))
	for i in range(0,len(arr_2D)):
		for j in range(0,len(arr_2D[i])):
			result[j][i] = arr_2D[i][j]
	return result
"""	
arr_2D = [[0,5,6],[3,5,7],[3,1,9],[9,17,4]]
print pivot(arr_2D)
sys.exit(0)
"""
def getSharpe(X_SHARPE, span):
	result = []
	for i in range(0, len(X_SHARPE)):
		if i <= span:
			start = 0
		else:
			start = i - span
		std = X_SHARPE[start : i+1].std()
		sharpe = 0
		if std != 0:
			sharpe = float(X_SHARPE[start : i+1].mean() / std)		
			
		result.append(float(sharpe))
		
	return result
	
	
	
def stochasticOscillator(hlc, span):
	#print hlc [0:10]
	result = []
	for i in range(0, len(hlc)):
		hlc_from = i-span if i>span else 0
		hlc_to = i+1 if i<len(hlc) else len(hlc)
		try:
			close = hlc[i][2]
			lo = getLo(hlc[hlc_from:hlc_to,1])
			hi = getHi(hlc[hlc_from:hlc_to][0])
			#numerator = float(hi/lo) if lo!=0 else 0
			k = (float((close - lo) / (hi - lo))) if (hi - lo)!=0 else 0
			result.append(k)
		except:
			print hlc_from, hlc_to, i
			raise
	d = moments.ewma(np.array(result).ravel(), span=3)
	return d
	
def getLo(vect):
	min = float("inf")
	for i in range(0,len(vect)):
		if vect[i] < min:
			min = vect[i]
	
	return min
	
def getHi(vect):
	max = 0
	for i in range(0,len(vect)):
		if vect[i] > max:
			max = vect[i]
	
	return max
	
def daysSinceHigh(highs):
	result = 0
	max = 0
	for i in range(0,len(highs)):
		if highs[i] > max:
			max = highs[i]
			result = i
	return len(highs) - result		

def daysSinceLow(lows):
	result = 0
	min = 1000
	for i in range(0,len(lows)):
		if lows[i] < min:
			min = lows[i]
			result = i
	return len(lows) - result

	
def mean_abs_dev(pop):
	n = float(len(pop))
	mean = sum(pop) / n
	diff = [ abs(x - mean) for x in pop ]
	return sum(diff) / n

start_ts = time.time() 

try:	
	"""	
	HP = []
	#for i in range(0,100):
	#	HP.append(randint(0,9))
	HP.append(1)
	HP.append(10)
	HP.append(11)
	HP.append(12)
	HP.append(120)

	#c1, t1 = stats_filters.hpfilter(HP[0:50], lamb=1600)
	c2, t2 = stats_filters.hpfilter(HP, lamb=1600)
	#print len(c1)
	print c2
	print t2

	sys.exit(0)
	"""
	x_mat, times = TSCreator.create_intraday_roll_up(['GLD'], False, '9:30:00','16:00:00', mins=5, ohlc=True)


	#print times[0:20]
	#print x_mat[0:20]
	#sys.exit(0)
	# sklearn preprocessor  normalizer
	"""
	to_str = lambda x: str(x)
	to_dec = lambda x: float(x.strip("%"))
	to_dec_volume = lambda x: float(x.strip("%"))/100000.00
	"""
	# import some data to play with
	#headers = ['date','time', 'o', 'h', 'l', 'c', 'v']
	#x_mat = genfromtxt('C:\\Users\\ffitch\\Downloads\\ETF_5MIN\\SPY.txt', delimiter=',', converters={0: to_str, 1: to_str, 2: to_dec, 3: to_dec, 4: to_dec, 5: to_dec, 6: to_dec_volume})
	#x_mat_QQQ = genfromtxt('QQQ.csv', delimiter=',', converters={0: to_str, 1: to_str, 2: to_dec, 3: to_dec, 4: to_dec, 5: to_dec, 6: to_dec_volume})
	"""
	df_spy = DataFrame.from_csv('SPY.csv', [1,2])
	df_qqq = DataFrame.from_csv('QQQ.csv', [1,2])

	joined = df_spy.join(df_qqq, how='inner')

	print len(joined)


	for i in range(0, len(x_mat)-10):
		if time.strptime(x_mat[i][1], "%H:%M").tm_hour < 11 or time.strptime(x_mat[i][1], "%H:%M").tm_hour >= 16:
			continue
		
		
		if time.strptime(x_mat[i+1][0] + " " + x_mat[i+1][1], "%m/%d/%Y %H:%M") 
		
	"""	

	X = []
	Y = []	
	V_MA = []

	CLOSE = []
	X_MA = []
	X_MA2 = []
	X_RM = []
	X_SHARPE = []
	X_SHARPE2 = []
	HL = []
	SO = []
	SO2 = []
	CHANGE_U = []
	CHANGE_D = []
	ACC_DIST = []
	BOLLINGER = []
	HP_FILTER = []
	KALMAN = []
	MACD_LINE = []
	MACD_SIGNAL = []
	OBV = [] 
	TR = [] #true range
	AU = [] # Aroon
	AD = []
	#CCI = [] #Commodity Channel Index
	TP = [] # Typical Price
	PMF = []
	NMF = []
	for i in range(10,len(x_mat)-5):	
		#if times[i].hour >= 15 or times[i].hour < 11:
		#	continue
		CLOSE.append(x_mat[i,c_ind])
		vol = x_mat[i][v_ind]
		#close = x_mat[i,c_ind]
		#HP_FILTER.append(close)
		#X_MA.append(close)
		#X_MA2.append(close)
		"""
		macd_fast = moments.ewma(np.array(CLOSE[len(CLOSE)-14:]).ravel(), span=14)
		macd_slow = moments.ewma(np.array(CLOSE[len(CLOSE)-26:]).ravel(), span=26)
		MACD_LINE.append(macd_fast[len(macd_fast)-1]-macd_slow[len(macd_slow)-1])
		macd_sig = moments.ewma(np.array(MACD_LINE[len(MACD_LINE)-9:]).ravel(), span=9)
		MACD_SIGNAL.append(macd_sig[len(macd_sig)-1])
		"""
		#HL.append(x_mat[i][h_ind]-x_mat[i][l_ind])
		
		change_up = CLOSE[len(CLOSE)-1] - CLOSE[len(CLOSE)-2] #x_mat[i+1][c_ind] - x_mat[i][c_ind]
		change_dn = CLOSE[len(CLOSE)-2] - CLOSE[len(CLOSE)-1] #x_mat[i][c_ind] - x_mat[i+1][c_ind]
		"""
		tp = float((x_mat[i,h_ind] + x_mat[i,l_ind] + x_mat[i,c_ind]) / 3)
		TP.append(tp)
		PMF.append((tp*vol) if change_up>0 else 0) # Positive Money Flow
		NMF.append((tp*vol) if change_dn>0 else 0) # Negative Money Flow
		
		AU.append(daysSinceHigh(x_mat[i-4:i+1,h_ind]))
		AD.append(daysSinceLow(x_mat[i-4:i+1,l_ind]))
		"""
		#X_SHARPE.append(x_mat[i][c_ind])
		#X_SHARPE2.append(x_mat[i][c_ind])
		SO.append(x_mat[i][h_ind:v_ind])
		#SO2.append(x_mat[i][h_ind:v_ind])
		
		CHANGE_U.append((change_up) if change_up>0 else 0)
		CHANGE_D.append((change_dn) if change_dn>0 else 0)
		
		
		if CLOSE[len(CLOSE)-1:len(CLOSE)] > CLOSE[len(CLOSE)-2:len(CLOSE)-1]:
			OBV.append(vol)
		elif CLOSE[len(CLOSE)-1:len(CLOSE)] == CLOSE[len(CLOSE)-2:len(CLOSE)-1]:
			OBV.append(0)
		elif CLOSE[len(CLOSE)-1:len(CLOSE)] < CLOSE[len(CLOSE)-2:len(CLOSE)-1]:
			OBV.append(-vol)
		"""
		high_t = x_mat[i][h_ind]
		low_t = x_mat[i][l_ind]
		close_t_minus1 = x_mat[i-1][c_ind]
		TR.append(max(high_t,close_t_minus1) - min(low_t,close_t_minus1))
		"""
		#acc_dist_prev = (ACC_DIST[len(ACC_DIST)-1]) if len(ACC_DIST)>0 else 0
		#ACC_DIST.append( acc_dist_prev + (vol * clv(x_mat[i][h_ind], x_mat[i][l_ind], x_mat[i][c_ind])) )
		
		#ewma10 = moments.ewma(np.array(X_MA).ravel(), span=10)
		
		EWMA10 = CLOSE[len(CLOSE)-10:len(CLOSE)]#x_mat[i-10:i+1,c_ind] #X_MA[0 if len(X_MA)<10 else len(X_MA)-10:len(X_MA)-1]
		try:
			BOLLINGER.append((CLOSE[len(CLOSE)-1] - np.mean(EWMA10)) / (np.std(EWMA10)) if np.std(EWMA10)!=0.0 else 0)
		except:
			print EWMA10
			raise
		
		#V_MA.append(x_mat[i][6])
		
		#arr_concat = np.array([[x_mat[i,c_ind]], [x_mat[i+1,c_ind]]])
		#KALMAN.append(arr_concat)
		
	#cycle, trend = stats_filters.hpfilter(HP_FILTER, lamb=1600)
	#sys.exit(0)
	#X_SHARPE = getSharpe(np.array(X_SHARPE).ravel(), 3)
	#X_SHARPE2 = getSharpe(np.array(X_SHARPE2).ravel(), 10)
	SO = stochasticOscillator(np.array(SO),3)
	#SO2 = stochasticOscillator(np.array(SO2),10)
	CHANGE_U = moments.ewma(np.array(CHANGE_U).ravel(), span=3)
	CHANGE_D = moments.ewma(np.array(CHANGE_D).ravel(), span=3)
	#TP_SMA = moments.rolling_mean(np.array(TP),window=20,min_periods=0)
	#KALMAN = np.array(KALMAN)
	#KALMAN.reshape(len(KALMAN[:,0:1]), len(KALMAN[1:,:]))
	#CHANGE_U = moments.rolling_mean(np.array(CHANGE_U).ravel(), window=5, min_periods=0)
	#CHANGE_D = moments.rolling_mean(np.array(CHANGE_D).ravel(), window=5, min_periods=0)
	#ACC_DIST1 = moments.ewma(np.array(ACC_DIST).ravel(), span=3) 
	#ACC_DIST2 = moments.ewma(np.array(ACC_DIST).ravel(), span=5) 


	#print SO[0:10]
	#print X_SHARPE[20:30]
	#print X_SHARPE2[20:30]

	#print len(X_MA)
	#print len(X_MA2)

	"""
	#X_MA = moments.rolling_mean(np.array(X_MA).ravel(), window=10, min_periods=0)
	#X_RM = moments.rolling_mean(np.array(X_MA).ravel(), window=5, min_periods=0)
	X_RM = moments.ewma(np.array(X_MA).ravel(), span=5)
	V_MA = moments.ewma(np.array(V_MA).ravel(), span=5)
	"""
	#ATR = moments.ewma(np.array(TR).ravel(), span=5)
	#print len(X_RM)

	for counter in range(0,len(CLOSE)-1):
		if counter < 100:
			continue
		#cycle, trend = stats_filters.hpfilter(CLOSE[counter-100 : counter], lamb=1600)
		#cycle, trend = stats_filters.cffilter(CLOSE[counter-100 : counter],low=6, high=32, drift=True)
		#HP_FILTER_WMA = moments.ewma(np.array(cycle).ravel(), span=100)
		#betas, Q, e = Kalman(np.array(KALMAN[counter-10:counter,:]))
		#mad = mean_abs_dev(TP[counter-20:counter+1])
		#nmf = sum(NMF[counter-3:counter+1])
		x = [#(calendar.timegm(time.strptime(x_mat[i+1][0] + " " + x_mat[i+1][1], "%m/%d/%Y %H:%M") ) - calendar.timegm(time.strptime(x_mat[i][0] + " " + x_mat[i][1], "%m/%d/%Y %H:%M") ))/60.00/10000.00,
				#	x_mat[i+1][2] - x_mat[i][2],
				#	x_mat[i+1][3] - x_mat[i][3],
				#	x_mat[i+1][4] - x_mat[i][4],
				#	x_mat[i+1][5] - x_mat[i][5]
				#	,x_mat[i+1][6] - x_mat[i][6]
				#	,float(V_MA[counter])
				#	,float(X_RM[counter] - float(X_MA[counter]))
				#	float(x_mat[i+1][0]) - float(x_mat[i][0])
				#	float(x_mat[i+1][1]) - float(x_mat[i][1])
				#	float(x_mat[i+1][3]) - float(x_mat[i][3])
				#	float(X_MA2[counter]) - float(X_MA[counter])
				#	float(HL[counter+1 if counter<len(HL)-1 else len(HL)-1] - HL[counter])
				#	times[i].hour
				#	float(X_SHARPE[counter] - X_SHARPE2[counter])
				#	,float(SO[counter]) - float(SO2[counter])
					 BOLLINGER[counter]
					,rsi(float(CHANGE_U[counter] / CHANGE_D[counter]) if CHANGE_D[counter] !=0 else 0)# - rsi(float(CHANGE_U2[counter] / CHANGE_D2[counter]))
					,SO[counter]
				#	,MACD_SIGNAL[counter] 
					,OBV[counter] # On balace volume
				#	,AU[counter]
				#	,AD[counter]
				#	,((TP[counter] - TP_SMA[counter]) / mad*0.015) if mad != 0 else 0
				#	,100 - 100/(1 + ((sum(PMF[counter-3:counter+1]) / nmf) if nmf != 0 else 0))
				#	,ATR[counter] # Avg True Range
				#	,MACD_LINE[counter]
				#	,CLOSE[counter-1] - (cycle[len(cycle)-1] + trend[len(trend)-1])
				#	,HP_FILTER_WMA[len(HP_FILTER_WMA)-1]
				#	,e[len(e)-1]
				#	,ACC_DIST1[counter] - ACC_DIST2[counter] # Chaikin oscillator
				#	,float(x_mat[i+1][2]) - float(x_mat[i][2])
			]
		X.append(x)
		
		if CLOSE[counter+1] - CLOSE[counter] > 0:
			y = 1
		else:
			y = 0
		Y.append(y)
		
	X = np.array(X)
	#print X[0:60]
	#preprocessing.scale(X, copy=False)
	"""
	scaler = preprocessing.StandardScaler()
	#scaler.fit(X)
	#X = scaler.transform(X)
	preprocessing.normalize(X, axis=0, copy=False)
	"""
	#preprocessing.normalize(X, axis=0, copy=False)
	scaler = preprocessing.StandardScaler(copy=False)
	scaler.fit(X)
	scaler.transform(X)
	#print X[0:150]
	"""
	X = pivot(X)
	for i in range(0,len(X)):
		x_row = X[i]
		X[i] = scale(x_row,-1,1)
	X=pivot(X)
	print X[0:30]
	"""
	Y = np.array(Y).ravel()
		
	X_train, X_test, y_train, y_test = cross_validation.train_test_split(X, Y, test_size=0.2, random_state=0)






	#model = GradientBoostingClassifier(n_estimators=100, min_samples_split=1000, max_depth=8, learning_rate=.03)
	#model = SVC(probability=True)#C=100,gamma=0.071, coef0=0.9, kernel='linear')#, kernel='poly', degree=2, coef0=1, verbose=True, max_iter=1000000)
	#model = ExtraTreesClassifier(n_estimators=100, min_samples_split=1000, max_depth=None)
	model = RandomForestClassifier(bootstrap=True, compute_importances=None,
				criterion='gini', max_depth=None, max_features='auto',
				min_density=None, min_samples_leaf=1000, min_samples_split=50,
				n_estimators=300, n_jobs=1, oob_score=False, random_state=42,
				verbose=0)
	#model = GaussianNB()
	#model = KNeighborsClassifier(n_neighbors=2)#, weights='uniform', algorithm='auto', leaf_size=30, p=2, metric='minkowski')
	#model = linear_model.LogisticRegression(C=1.0, class_weight=None, dual=False, fit_intercept=True, intercept_scaling=1, penalty='l2', tol=0.0001)#(C=1, fit_intercept=True)
	model.fit(X_train, y_train)
	#Z1 = model.predict_proba(X_train)
	#print Z1
	#print stats.scoreatpercentile(Z,99)
	#print model
	#print model.coef_
	#print model.intercept_
	G = model.predict_proba(X_train)[:,1]
	high = stats.scoreatpercentile(G, 95)
	low = stats.scoreatpercentile(G,5)
	Z = model.predict_proba(X_test)

	taf = ThresholdScoreFunc(95,5,True, high, low)
	print "Runtime: {0}".format(time.time() - start_ts)
	print taf(y_test, Z[:,1])
	print model.feature_importances_
	# Compute confusion matrix 
	"""
	cm = confusion_matrix(y_test, Z)
	total_acc = float(cm[0][0] + cm[1][1]) / np.sum(cm)
	print cm
	print total_acc
	"""
except:
	print "Runtime: {0}".format(time.time() - start_ts)
	raise
