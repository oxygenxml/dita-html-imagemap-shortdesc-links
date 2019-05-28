<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
    exclude-result-prefixes="ditamsg xs"
    version="2.0">
    <!-- imagemap -->
    <xsl:template match="*[contains(@class,' ut-d/imagemap ')]" name="topic.ut-d.imagemap">
        <div>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
            
            <!-- the image -->
            <img usemap="#{generate-id()}">
                <xsl:apply-templates select="." mode="imagemap-border-attribute"/>
                <!-- Process the 'normal' image attributes, using this special mode -->
                <xsl:apply-templates select="*[contains(@class,' topic/image ')]" mode="imagemap-image"/>
            </img>
            
            <map name="{generate-id(.)}" id="{generate-id(.)}">
                
                <xsl:for-each select="*[contains(@class,' ut-d/area ')]">
                    <area>
                        
                        <!-- if no xref/@href - error -->
                        <xsl:choose>
                            <xsl:when test="*[contains(@class,' topic/xref ')]/@href">
                                <!-- special call to have the XREF/@HREF processor do the work -->
                                <xsl:apply-templates select="*[contains(@class, ' topic/xref ')]" mode="imagemap-xref"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="." mode="ditamsg:area-element-without-href-target"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <!-- create ALT text from XREF content-->
                        <!-- if no XREF content, use @HREF, & put out a warning -->
                        <xsl:choose>
                            <xsl:when test="*[contains(@class, ' topic/xref ')]">
                                <xsl:variable name="alttext">
                                    <xsl:choose>
                                        <!-- RADU C: Use short description when available -->
                                        <xsl:when test="*[contains(@class, ' topic/xref ')]/*[contains(@class, ' topic/desc ')]">
                                            <xsl:apply-templates select="*[contains(@class, ' topic/xref ')]/*[contains(@class, ' topic/desc ')]" mode="text-only"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:apply-templates select="*[contains(@class, ' topic/xref ')]/node()[not(contains(@class, ' topic/desc '))]" mode="text-only"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:attribute name="alt"><xsl:value-of select="normalize-space($alttext)"/></xsl:attribute>
                                <xsl:attribute name="title"><xsl:value-of select="normalize-space($alttext)"/></xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="." mode="ditamsg:area-element-without-linktext"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <!-- if not valid shape (blank, rect, circle, poly); Warning, pass thru the value -->
                        <xsl:variable name="shapeval"><xsl:value-of select="*[contains(@class,' ut-d/shape ')]"/></xsl:variable>
                        <xsl:attribute name="shape">
                            <xsl:value-of select="$shapeval"/>
                        </xsl:attribute>
                        <xsl:variable name="shapetest" select="concat('-',$shapeval,'-')" as="xs:string"/>
                        <xsl:choose>
                            <xsl:when test="contains('--rect-circle-poly-default-',$shapetest)"/>
                            <xsl:otherwise>
                                <xsl:apply-templates select="." mode="ditamsg:area-element-unknown-shape">
                                    <xsl:with-param name="shapeval" select="$shapeval"/>
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <!-- if no coords & shape<>'default'; Warning, pass thru the value -->
                        <xsl:variable name="coordval"><xsl:value-of select="*[contains(@class,' ut-d/coords ')]"/></xsl:variable>
                        <xsl:choose>
                            <xsl:when test="string-length($coordval)>0 and not($shapeval='default')">
                                <xsl:attribute name="coords">
                                    <xsl:value-of select="$coordval"/>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="." mode="ditamsg:area-element-missing-coords"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </area>
                </xsl:for-each>
            </map>
            <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        </div>
    </xsl:template>
</xsl:stylesheet>